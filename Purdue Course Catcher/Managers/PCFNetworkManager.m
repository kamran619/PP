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
#import "PCCDataManager.h"
#import "KPLightBoxManager.h"
#import "PCCHUDManager.h"

#import "PCCFacebookLoginViewController.h"
#import "PCCFTUEViewController.h"
#import "PCCMenuViewController.h"
#import "PCCAppDelegate.h"
#import "PCCObject.h"

#define SERVER_COMMAND @"command"
#define kData @"data"
#define kCRN @"crn"
#define kClassLink @"classLink"
#define kCourseNumber @"courseNumber"
#define kTerm @"term"

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
        [self registerForNotifications];
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
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:kNotificationReceivedFTUEComplete object:nil];
}

-(void)processNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:kNotificationReceivedFTUEComplete]) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
        [dictionary setObject:[[[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kEducationInfoDictionary] objectForKey:kName] forKey:kNickname];
        [dictionary setObject:@YES forKey:kViewMySchedule];
        [dictionary setObject:@YES forKey:kFindByMajor];
        [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kSettings InDictionary:DataDictionaryUser];
        [self prepareDataForCommand:ServerCommandInitialization withDictionary:notification.userInfo];
    }
    
}
-(void)fireTimeout:(NSTimer *)timer
{
    if ([self.delegate respondsToSelector:@selector(responseFromServer:initialRequest:wasSuccessful:)]) {
        [self.delegate responseFromServer:nil initialRequest:timer.userInfo wasSuccessful:NO];
    }
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
            if (theStream == self.outputStream) self.initializedSocket = YES;
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
                        NSData *JSONData = [str dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:&error];
                        [self processServerData:dictionary];
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


//process the server response
-(void)processServerData:(NSDictionary *)feedback
{
    [self.timoutTimer invalidate];
    
    NSNumber *command = [feedback objectForKey:@"command"];
    NSNumber *error = [feedback objectForKey:@"error"];
    
    if ([self.delegate respondsToSelector:@selector(responseFromServer:initialRequest:wasSuccessful:)]) {
        [self.delegate responseFromServer:feedback initialRequest:nil wasSuccessful:(error.integerValue == 0) ? YES : NO];
    }
    
    
    switch (command.intValue) {
        case ServerCommandCatch:
            break;
            
        case ServerCommandUnCatch:
            break;
            
        case ServerCommandInitialization:
        {
            [Helpers setInitialization];
            [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Registered" success:YES];
            if ([[[UIApplication sharedApplication].delegate window].rootViewController isKindOfClass:[PCCFTUEViewController class]]) {
                    //FTUE is root vc
                [[UIApplication sharedApplication].delegate window].rootViewController = [Helpers viewControllerWithStoryboardIdentifier:@"PCCTabBar"];
            }else {
                //
                [[[UIApplication sharedApplication].delegate window].rootViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        default:
            break;
    }
    
    
    
    /*if ([command isEqualToString:@"CLASS_RATING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClassesReceived" object:data];
    }else if ([command isEqualToString:@"PROFESSOR_RATING"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProfessorRatingsReceived" object:data];
    }else if ([command isEqualToString:@"SUBMIT_CLASS_REVIEW"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReviewResponseReceived" object:error];
    }else if ([command isEqualToString:@"COMPLETE_CLASS_RATING"]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"ServerClassReceived" object:data.lastObject];
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
    }*/
}

-(void)prepareDataForCommand:(ServerCommand)command withDictionary:(NSDictionary *)dict
{
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:2];
    [dictionary setObject:[NSNumber numberWithInt:command] forKey:SERVER_COMMAND];
    
    switch (command) {
        case ServerCommandCatch:
        {
            [[KPLightBoxManager sharedInstance] showLightBox];
            [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Catching..."];
            
            NSString *identifier = [Helpers getPUID];
            
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
            
            [dataDictionary setObject:identifier forKey:kUsername];
            [dataDictionary setObject:[dict objectForKey:kCRN] forKey:kCRN];
            [dataDictionary setObject:[dict objectForKey:kClassLink] forKey:kClassLink];
            [dataDictionary setObject:[dict objectForKey:kCourseNumber] forKey:kCourseNumber];
            [dataDictionary setObject:[dict objectForKey:kTerm] forKey:kTerm];
            [dictionary setObject:dataDictionary.copy forKey:kData];
            
            NSError *error;
            NSMutableData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error].mutableCopy;
            const char* newLine = "\r\n";
            [JSONData appendBytes:(const uint8_t*)newLine length:2];
            //pass to timer
            if (!error) [self sendDataToServer:JSONData.copy forCommand:command];
        }
            break;
        case ServerCommandUnCatch:
        {
            [[KPLightBoxManager sharedInstance] showLightBox];
            [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Uncatching..."];
            
            NSString *identifier = [Helpers getPUID];
            
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
            
            [dataDictionary setObject:identifier forKey:kUsername];
            [dataDictionary setObject:[dict objectForKey:kCRN] forKey:kCRN];
            [dataDictionary setObject:[dict objectForKey:kTerm] forKey:kTerm];
            
            [dictionary setObject:dataDictionary.copy forKey:kData];
            
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
        }
            break;
        case ServerCommandInitialization:
        {
            /*Note, we are now authenticating students first, so in the init packet we will send their purdue username, name, major, classification, and if applicable device token and fbid*/
            
            //create dictionary to send
            NSString *identifier = [dict objectForKey:@"id"];
            NSString *token = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kDeviceToken];
            
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
            if (token) [dataDictionary setObject:token forKey:kDeviceToken];
            if (identifier) [dataDictionary setObject:identifier forKey:kUserID];
            
            NSDictionary *schoolInfo = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kEducationInfoDictionary];
            NSString *purdueUsername = [Helpers getPUID];
            
            [dataDictionary setObject:schoolInfo.copy forKey:kEducationInfoDictionary];
            [dataDictionary setObject:purdueUsername forKey:kUsername];
            [dictionary setObject:dataDictionary.copy forKey:kData];
            
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
        }
            break;
            
        case ServerCommandUpdate:
        {
            NSString *identifier = [Helpers getFacebookIdentifier];
            if (!identifier) identifier = @"simulator_id";
            NSString *token = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kDeviceToken];
            
            NSDictionary *schoolInfo = (!dict) ? [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kEducationInfoDictionary] : dict;
            
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
            [dataDictionary setObject:token forKey:kDeviceToken];
            [dataDictionary setObject:identifier forKey:kUserID];
            [dataDictionary setObject:[Helpers getPUID] forKey:kUsername];
            if (schoolInfo) [dataDictionary setObject:schoolInfo forKey:kEducationInfoDictionary];
            
            [dictionary setObject:dataDictionary.copy forKey:kData];
            
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
        }
            break;
            
        case ServerCommandSendSchedule:
        {
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
            
            NSArray *add = [dict objectForKey:@"add"];
            if (add.count > 0) {
                [dataDictionary setObject:add forKey:@"add"];
            }
            NSArray *remove = [dict objectForKey:@"remove"];
            if (remove.count > 0) {
                [dataDictionary setObject:remove forKey:@"remove"];
            }
            
            if (add.count == 0 && remove.count == 0) return;
            
            NSString *user = [Helpers getPUID];
            [dataDictionary setObject:user forKey:kUsername];
            
            PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow];
            [dataDictionary setObject:term.value forKey:@"term"];
            [dictionary setObject:dataDictionary forKey:kData];
            
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
        }
            break;
            
        case ServerCommandSettings:
        {
            NSString *identifier = [Helpers getPUID];
            
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
            [dataDictionary setObject:identifier forKey:kUsername];
            
            NSDictionary *settingsDictionary = dict;//[[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kSettings];
            
            [dataDictionary setObject:settingsDictionary.copy forKey:kSettings];
            [dictionary setObject:dataDictionary.copy forKey:kData];
            
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
        }
            break;
            
        case ServerCommandPurchase:
        {
            NSString *identifier = [Helpers getPUID];
            
            NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
            [dataDictionary setObject:identifier forKey:kUsername];
            
            NSDictionary *purchaseDictionary = dict;
            [dataDictionary setObject:[purchaseDictionary objectForKey:kPurchasedItem] forKey:kPurchasedItem];
            [dictionary setObject:dataDictionary.copy forKey:kData];
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
            break;
        }
            
        case ServerCommandViewRatings:
        {
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
            break;

        }
            
        case ServerCommandViewCourseRating:
        {
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
            break;
            
        }
            
        case ServerCommandViewProfessorRating:
        {
            NSError *error;
            if (!error) [self sendDataToServer:[self packageCommandIntoJSON:dictionary error:&error] forCommand:command];
            break;
            
        }
        
        default:
            break;
    }
}

-(NSData *)packageCommandIntoJSON:(NSDictionary *)dictionary error:(NSError **)error
{
    NSMutableData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:error].mutableCopy;
    const char* newLine = "\r\n";
    [JSONData appendBytes:(const uint8_t*)newLine length:2];
    return JSONData;

}

-(void)sendDataToServer:(NSData *)data forCommand:(ServerCommand)command
{
    if (!self.initializedSocket) {
        [self initSocket];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:@selector(sendDataToServer:forCommand:)]];
        [invocation setSelector:@selector(sendDataToServer:forCommand:)];
        [invocation setTarget:self];
        [invocation setArgument:&data atIndex:2];
        [invocation setArgument:&command atIndex:3];
        [invocation retainArguments];
        [invocation performSelector:@selector(invoke) withObject:nil afterDelay:1.0f];
        return;
    }
    
    [Helpers asyncronousBlockWithName:@"Send Data" AndBlock:^{
        
        if ([self.outputStream hasSpaceAvailable]) {
            self.timoutTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(fireTimeout:) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.timoutTimer forMode:NSDefaultRunLoopMode];
                [self.outputStream write:[data bytes] maxLength:[data length]];
                [self.outputStream write:@"\n".UTF8String maxLength:1];
        }else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(responseFromServer:initialRequest:wasSuccessful:)]) [self.delegate responseFromServer:nil initialRequest:self.timoutTimer.userInfo wasSuccessful:NO];
        }
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
