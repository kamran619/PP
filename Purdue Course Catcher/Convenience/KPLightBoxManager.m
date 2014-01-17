//
//  KPLightBoxManager.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "KPLightBoxManager.h"
#import "UIView+Animations.h"

@implementation KPLightBoxManager

static KPLightBoxManager *_sharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[KPLightBoxManager alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        
        self.lightBoxView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.lightBoxView.backgroundColor = [UIColor blackColor];
        self.alpha = 0.6f;
        self.lightBoxView.alpha = self.alpha;
        self.animationDuration = 0.4f;
        
    }
    
    return self;
}
-(void)showLightBox
{
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    self.lightBoxView.alpha = 0.0f;
    self.lightBoxView.frame = view.bounds;
    [view addSubview:self.lightBoxView];
    [self.lightBoxView fadeInWithAlpha:self.alpha];
}

-(void)dismissLightBox
{
    [self.lightBoxView fadeOut];
    [self.lightBoxView removeFromSuperview];
}

@end
