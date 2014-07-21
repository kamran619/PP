//
//  KPNotificationCenter.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 7/10/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "KPNotificationCenter.h"
#import "PCCNotificationViewController.h"
#import "KPLightBoxManager.h"

@implementation KPNotificationCenter

static KPNotificationCenter *_sharedInstance = nil;

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[KPNotificationCenter alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _notifications = [NSMutableOrderedSet orderedSet];
        _isDisplayingNotification = NO;
    }
    
    return self;
}

- (void)addNotification:(PCCNotificationViewController *)notificationVC
{
    if ([self.notifications containsObject:notificationVC]) return;
    
    if ([self.notifications count] == 0) {
        self.isDisplayingNotification = YES;
        [[KPLightBoxManager sharedInstance] showLightBox];
    }else {
        PCCNotificationViewController *topNotification = [self topMostNotification];
        topNotification.view.alpha = 0.0f;
    }
    
    [self.notifications addObject:notificationVC];
    
    UIView *topMostView = [UIApplication sharedApplication].keyWindow;
    [notificationVC presentNotificationOnView:topMostView];
    
}

- (void)removeNotification:(PCCNotificationViewController *)notificationVC
{
    if (![self.notifications containsObject:notificationVC]) return;

    [self.notifications removeObject:notificationVC];
    
    
    if ([self.notifications count] == 0) {
        self.isDisplayingNotification = NO;
        [[KPLightBoxManager sharedInstance] dismissLightBox];
    }else {
        PCCNotificationViewController *topNotification = [self topMostNotification];
        topNotification.view.alpha = 1.0f;
    }
    
}

-(PCCNotificationViewController *)topMostNotification
{
    return [self.notifications lastObject];
}

- (void)removeTopmostNotification
{
    if ([self.notifications count] == 0) return;
    
    PCCNotificationViewController *vc = [self.notifications lastObject];
    [self removeNotification:vc];
}

@end
