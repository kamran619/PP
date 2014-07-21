//
//  KPNotificationCenter.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 7/10/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCCNotificationViewController;

@interface KPNotificationCenter : NSObject

+ (instancetype)sharedInstance;
- (id)init;

- (void)addNotification:(PCCNotificationViewController *)notificationVC;

- (void)removeNotification:(PCCNotificationViewController *)notificationVC;
- (void)removeTopmostNotification;


@property (nonatomic, strong) NSMutableOrderedSet *notifications;
@property (nonatomic, assign) BOOL isDisplayingNotification;

@end
