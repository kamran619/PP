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


-(void)displayHUDWithCaption:(NSString *)caption withImage:(UIImage *)image onView:(UIView *)view
{
    self.timer = [NSTimer timerWithTimeInterval:15 target:self selector:@selector(showCloseButton:) userInfo:nil repeats:NO];
    self.hudLabel.text = caption;
    if (image) {
        [self.activityIndicator setHidden:YES];
        self.imageView.image = image;
        [self.imageView fadeIn];
    }else {
        [self.activityIndicator setHidden:NO];
    }
    self.alpha = 0.0f;
    self.center = view.center;
    [view addSubview:self];
    [self fadeIn];
}
-(void)displayHUDWithCaption:(NSString *)caption onView:(UIView *)view
{
    [self.activityIndicator startAnimating];
    [self displayHUDWithCaption:caption withImage:nil onView:view];
}

-(void)hideHUD
{
    [self.timer invalidate];
    self.timer = nil;
    [self fadeOut];
    [self removeFromSuperview];
    [self initialize];
}

-(void)initialize
{
    [self.activityIndicator stopAnimating];
    [self.imageView setAlpha:0.0f];
}

-(void)showCloseButton
{
    [self.closeButton setHidden:NO];
    [self.class wiggle];
}

-(IBAction)closeButtonPressed:(id)sender
{
    [self hideHUD];
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
