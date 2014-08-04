//
//  KPTransitionManager.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "KPTransitionManager.h"

#define TAG_FOR_BLACKGROUND_VIEW 768

@implementation KPTransitionManager

static KPTransitionManager *_singleton = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[KPTransitionManager alloc] init];
    });
    
    return _singleton;
}

- (id)init {
    if (self = [super init]) {
        self.stackOfViewControllers = [NSMutableArray array];
    }
    
    return self;
}

- (void)pushViewControllerToScreen:(UIViewController *)viewController {
    [self pushViewControllerToScreen:viewController withAnimation:KPTransitionTypeFromRight];
}

- (void)pushViewControllerToScreen:(UIViewController *)viewController withAnimation:(KPTransitionType)animation {

    @synchronized(self.stackOfViewControllers) {
        UIViewController *viewControllerToScaleBack = [self getTopViewController];
        CGRect oldViewFrame = viewControllerToScaleBack.view.frame;
        CGAffineTransform scale = CGAffineTransformMakeScale(0.8, 0.8);
        UIView *blackroundView = [[UIView alloc] initWithFrame:viewControllerToScaleBack.view.bounds];
        [blackroundView setAlpha:0.0];
        [blackroundView setBackgroundColor:[UIColor blackColor]];
        [blackroundView setTag:TAG_FOR_BLACKGROUND_VIEW];
        [viewControllerToScaleBack.view addSubview:blackroundView];
        
        
        [self.stackOfViewControllers addObject:viewController];
        
        [viewController.view setFrame:[self getFrameForViewController:viewController withAnimationType:animation]];
        [viewController beginAppearanceTransition:YES animated:YES];
        [[self getWindow] addSubview:viewController.view];
        
        
        [UIView animateWithDuration:0.35f animations:^{
            viewControllerToScaleBack.view.transform = scale;
            blackroundView.alpha = 0.7;
        }];
        
        [UIView animateWithDuration:0.25f delay:0.05f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewController.view.frame = CGRectMake(0, oldViewFrame.size.height - CGRectGetHeight(viewController.view.frame), CGRectGetWidth(viewController.view.frame), CGRectGetHeight(viewController.view.frame));
        }completion:^(BOOL finished) {
            if (finished) {
                [viewController endAppearanceTransition];
            }
        }];
    }
}


- (void)popTopViewController {
    [self popViewController:[self getTopViewController] withAnimationType:KPTransitionTypeToRight];
}

- (void)popTopViewControllerWithAnimationType:(KPTransitionType)animationType {
    [self popViewController:[self getTopViewController] withAnimationType:animationType];
}

- (void)popViewController:(UIViewController *)viewControllerToPop withAnimationType:(KPTransitionType)animationType {
    
    @synchronized(self.stackOfViewControllers) {
        [self.stackOfViewControllers removeObject:viewControllerToPop];
        
        [viewControllerToPop beginAppearanceTransition:NO animated:YES];
        
        [UIView animateWithDuration:0.25f animations:^{
            viewControllerToPop.view.frame = [self getFrameForViewController:viewControllerToPop withAnimationType:animationType];
        } completion:^(BOOL finished) {
            if (finished) {
                [viewControllerToPop.view removeFromSuperview];
                [viewControllerToPop endAppearanceTransition];
            }
        }];
        
        UIViewController *viewControllerToScaleUp = [self getTopViewController];
        CGAffineTransform scale = CGAffineTransformMakeScale(0.8, 0.8);
        viewControllerToScaleUp.view.transform = scale;
        
        UIView *blackgroundView = [self getViewFromTag:TAG_FOR_BLACKGROUND_VIEW forViewController:viewControllerToScaleUp];
        
        [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewControllerToScaleUp.view.transform = CGAffineTransformIdentity;
            [blackgroundView setAlpha:0.0f];
        }completion:^(BOOL finished) {
            if (finished) {
                [blackgroundView removeFromSuperview];
            }
        }];
    }
}

- (UIView *)getViewFromTag:(int)tag forViewController:(UIViewController *)vc {
    for (UIView *view in vc.view.subviews) {
        if (view.tag == tag) return view;
    }
    
    return nil;
}

- (CGRect) getFrameForViewController:(UIViewController *)viewController withAnimationType:(KPTransitionType)animationType {
    CGRect frame = CGRectZero;
    CGRect vcFrame = viewController.view.frame;
    CGRect windowFrame = [[[[self getWindow] rootViewController] view] frame];
    
    switch (animationType) {
        case KPTransitionTypeFromLeft:
            frame.origin.x = -CGRectGetWidth(windowFrame);
            break;
        case KPTransitionTypeFromBottom:
            frame.origin.y = CGRectGetHeight(windowFrame);
            break;
        case KPTransitionTypeFromRight:
            frame.origin.x = CGRectGetWidth(windowFrame);
            break;
        case KPTransitionTypeFromTop:
            frame.origin.y = CGRectGetHeight(windowFrame);
            break;
        case KPTransitionTypeToLeft:
            frame.origin.x = -CGRectGetWidth(windowFrame);
            break;
        case KPTransitionTypeToBottom:
            frame.origin.y = CGRectGetHeight(windowFrame);
            break;
        case KPTransitionTypeToTop:
            frame.origin.y = -CGRectGetHeight(windowFrame);
            break;
        case KPTransitionTypeToRight:
            frame.origin.x = CGRectGetWidth(windowFrame);
            break;
        default:
            break;
    }
    
    frame.size.width = CGRectGetWidth(vcFrame);
    frame.size.height = CGRectGetHeight(vcFrame);
    
    return frame;
}

- (UIViewController *)getTopViewController {
    if (self.stackOfViewControllers.count == 0) {
        return [[self getWindow] rootViewController];
    }else {
        return [self.stackOfViewControllers lastObject];
    }
}

- (UIWindow *)getWindow {
    id delegate = [[UIApplication sharedApplication] delegate];
    UIWindow *mainWindow = [delegate window];
    return mainWindow;
}

@end
