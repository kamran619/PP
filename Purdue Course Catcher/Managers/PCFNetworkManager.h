//
//  PCFNetworkManager.h
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 10/12/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ServerCommand
{
    ServerCommandCatch = 0,
    ServerCommandUnCatch = 1,
    ServerCommandInitialization = 2,
    ServerCommandUpdate = 3,
    ServerCommandSendSchedule = 4,
    ServerCommandSettings = 5,
    ServerCommandPurchase = 6
    
} typedef ServerCommand;

@protocol PCFNetworkDelegate <NSObject>
-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success;
@end

/*
 NSNumber *command = [dictionary objectForKey:@"command"];
 NSNumber *error = [dictionary objectForKey@"error"]];
 NSDictionary *data = [dictionary objectForKey:@"data"];
 */

@interface PCFNetworkManager : NSObject <NSStreamDelegate>

@property (nonatomic, assign) BOOL initializedSocket;
@property (nonatomic, assign) BOOL internetActive;

@property (nonatomic, strong) NSTimer *timoutTimer;
-(void)fireTimeout:(NSTimer *)timer;

@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic) id <PCFNetworkDelegate>delegate;


+(instancetype) sharedInstance;

-(void)processServerData:(NSDictionary *)data;
-(void)sendDataToServer:(NSData *)data forCommand:(ServerCommand)command;
-(void)prepareDataForCommand:(ServerCommand)command withDictionary:(NSDictionary *)dict;

@end
