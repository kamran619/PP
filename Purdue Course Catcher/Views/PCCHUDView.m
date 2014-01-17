//
//  PCCHUDView.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCHUDView.h"
#import "UIView+Animations.h"
@implementation PCCHUDView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)displayHUDWithCaption:(NSString *)caption onView:(UIView *)view
{
    
    self.hudLabel.text = caption;
    [self.activityIndicator startAnimating];
    self.alpha = 0.0f;
    self.center = view.center;
    [view addSubview:self];
    [self fadeIn];
}

-(void)hideHUD
{
    [self fadeOut];
    [self removeFromSuperview];
    [self initialize];
}

-(void)initialize
{
    [self.activityIndicator stopAnimating];
    [self.imageView setAlpha:0.0f];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
