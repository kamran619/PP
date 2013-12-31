//
//  PCFNetworkManager.m
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 10/12/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCFNetworkManager.h"
#import "Reachability.h"
#import "Helpers.h"

@interface PCFNetworkManager()
-(void)checkNetworkStatus:(NSNotification *)notification;
-(void)tearDownSocket;
-(void)initSocket;
@end

@implementation PCFNetworkManager
{
    Reachability *internetReachable;
    NSString *buffer;
    BOOL incompleteBuffer;
}
static PCFNetworkManager *_sharedInstance = nil;

#pragma mark Private Methods

-(void) checkNetworkStatus:(NSNotification *)notification
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetActive = YES;
            [self initSocket];
            break;
        }
        case ReachableViaWWAN:
        {
            self.internetActive = YES;
            [self initSocket];
            break;
        }
    }
    
}

+(instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PCFNetworkManager alloc] init];
    });
    return _sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        self.initializedSocket = NO;
        internetReachable = [Reachability reachabilityForInternetConnection];
        [internetReachable startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initSocket) name:@"connectToServer" object:nil];
        [self checkNetworkStatus:nil];
    }
    return self;
}

-(void)initSocket
{
    if (self.initializedSocket || self.inputStream.streamStatus == NSStreamStatusOpen || self.outputStream.streamStatus == NSStreamStatusOpen) return;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef) SERVER_ADDRESS, PORT, &readStream, &writeStream);
    self.inputStream =  (__bridge_transfer NSInputStream *)readStream;
    [self.inputStream setDelegate:self];
    [self.inputStream open];
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [self.outputStream setDelegate:self];
    [self.outputStream open];
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.initializedSocket = YES;
}

-(void)tearDownSocket
{
    [self.inputStream close];
    [self.outputStream close];
    self.inputStream = nil;
    self.outputStream = nil;
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.initializedSocket = NO;
}
#pragma mark - NSStreamDelegate methods
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent{
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventEndEncountered:
        {
            NSLog(@"The end of a stream has been encountered.");
            [self tearDownSocket];
            break;
        }
        case NSStreamEventErrorOccurred:
        {
            if (theStream == self.outputStream) NSLog(@"NETWORK ERROR:\n%@", theStream.streamError.description);
                [self tearDownSocket];
            break;
        }
        case NSStreamEventHasBytesAvailable:
        {
            //can read input
            if (theStream == self.inputStream) {
                if (self.inputStream.hasBytesAvailable) {
                    uint8_t buf[4096];
                    long len = 0;
                    len = [self.inputStream read:buf maxLength:4096];
                    if(len > 0 && len <= 4096) {
                        NSError *error;
                        NSString *str = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                        NSArray *array = [str componentsSeparatedByString:@"*/*"];
                        if (array.count == 1) {
                            if (!buffer) {
                                buffer = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                            }else {
                                buffer = [buffer stringByAppendingString:[[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding]];
                            }
                            
                            incompleteBuffer = YES;
                            return;
                        }
                        if (incompleteBuffer) {
                            incompleteBuffer = NO;
                            NSString *bufferedDate = [[NSString alloc] initWithBytes:buf length:len encoding:NSUTF8StringEncoding];
                            NSString *strBuff = [NSString stringWithFormat:@"%@%@", buffer, bufferedDate];
                            buffer = nil;
                            array = [strBuff componentsSeparatedByString:@"*/*"];
                        }
                        for (int i = 0; i < array.count - 1; i++) {
                            NSData *data = [[array objectAtIndex:i] dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                            if (error) {
                                NSLog(@"Still error");
                            }else {
                                [self processServerData:dictionary];
                            }
                        }
                    }else {
                        NSLog(@"\nlen is %ld\n" , len);
                    }
                }else {
                    NSLog(@"no buffer!");
                }
            }
            break;
        }
        case NSStreamEventHasSpaceAvailable:
        {
            //if (theStream == outputStream) {
            //}
            break;
        }case NSStreamEventNone:
        {
            break;
        }
            // continued ...
    }
}


-(void)processServerData:(NSDictionary *)feedback
{
    NSString *command = [feedback objectForKey:@"command"];
    NSNumber *error = [feedback objectForKey:@"error"];
    NSArray *data = [feedback objectForKey:@"data"];
    
    if ([command isEqualToString:@"CLASS_RATING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassesReceived" object:data];
    }else if ([command isEqualToString:@"PROFESSOR_RATING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfessorRatingsReceived" object:data];
    }else if ([command isEqualToString:@"SUBMIT_CLASS_REVIEW"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReviewResponseReceived" object:error];
    }else if ([command isEqualToString:@"COMPLETE_CLASS_RATING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerClassReceived" object:data.lastObject];
    }else if ([command isEqualToString:@"SUBMIT_PROFESSOR_REVIEW"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReviewResponseReceived" object:error];
    }else if ([command isEqualToString:@"COMPLETE_CLASS_COMMENTS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerClassCommentsReceived" object:feedback];
    }else if ([command isEqualToString:@"COMPLETE_PROFESSOR_RATING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerResponseReceived" object:data.lastObject];
    }else if ([command isEqualToString:@"COMPLETE_PROFESSOR_COMMENTS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ServerCommentsReceived" object:feedback];
    }else if ([command isEqualToString:@"ADD_CLASS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WatcherResponse" object:feedback];
    }else if ([command isEqualToString:@"REMOVE_CLASS"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WatcherResponse" object:feedback];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
