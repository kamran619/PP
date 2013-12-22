//
//  PCFNetworkManager.h
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 10/12/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFNetworkManager : NSObject <NSStreamDelegate>

@property (nonatomic, assign) BOOL initializedSocket;
@property (nonatomic, assign) BOOL internetActive;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSInputStream *inputStream;

+(instancetype) sharedInstance;

-(void)processServerData:(NSDictionary *)data;

@end
