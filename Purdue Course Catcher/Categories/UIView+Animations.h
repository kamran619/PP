//
//  UIView+Animations.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/31/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animations)

-(void)fadeIn;
-(void)fadeInWithDuration:(CGFloat)duration alpha:(CGFloat)alpha;
-(void)fadeInWithAlpha:(CGFloat)alpha;
-(void)fadeOut;
@end
