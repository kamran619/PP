//
//  UIView+Animations.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/31/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "UIView+Animations.h"

@implementation UIView (Animations)

#define ANIMATION_DURATION 0.25f
-(void)fadeIn
{
    [self fadeInWithAlpha:1.0f];
}

-(void)fadeInWithAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self setAlpha:alpha];
    }completion:nil];
}

-(void)fadeInWithDuration:(CGFloat)duration alpha:(CGFloat)alpha
{
    [UIView animateWithDuration:duration animations:^{
        [self setAlpha:alpha];
    }completion:nil];
}

-(void)fadeOut
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(fadeOut) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self setAlpha:0.0f];
    }completion:nil];
}

#pragma mark Slide methods
-(void)slideIn
{
    //self.transform = CGAffineTransformMakeScale(0, -self.frame.size.height);
    [UIView animateWithDuration:.75f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        //self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, -40);
        self.frame = CGRectMake(0, 60, self.frame.size.width, self.frame.size.height);
    }completion:nil];
}

-(void)slideOut
{
    [UIView animateWithDuration:.75f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(0, -60, self.frame.size.width, self.frame.size.height);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
