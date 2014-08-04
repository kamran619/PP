//
//  KPTransitionManager.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPTransitionManager : NSObject

enum KPTransitionType {
    KPTransitionTypeFromBottom,
    KPTransitionTypeFromLeft,
    KPTransitionTypeFromTop,
    KPTransitionTypeFromRight,
    KPTransitionTypeToBottom,
    KPTransitionTypeToLeft,
    KPTransitionTypeToTop,
    KPTransitionTypeToRight
} typedef KPTransitionType;


+ (instancetype)sharedInstance;

- (void)pushViewControllerToScreen:(UIViewController *)viewController;
- (void)pushViewControllerToScreen:(UIViewController *)viewController withAnimation:(KPTransitionType)animation;

- (void)popViewController:(UIViewController *)viewControllerToPop withAnimationType:(KPTransitionType)animationType;
- (void)popTopViewControllerWithAnimationType:(KPTransitionType)animationType;
- (void)popTopViewController;

@property(nonatomic, strong) NSMutableArray *stackOfViewControllers;


@end
