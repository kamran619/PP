//
//  PCCHUDManager.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCHUDManager.h"
#import "PCCHUDView.h"
#import "UIView+Animations.h"
#import "KPLightBoxManager.h"

@implementation PCCHUDManager

static PCCHUDManager *_sharedInstance = nil;

+(id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PCCHUDManager alloc] init];
    });
    return _sharedInstance;
}

-(PCCHUDView *)hudView
{
    if (!_hudView) {
            _hudView = [[[NSBundle mainBundle] loadNibNamed:@"PCCHUDView" owner:self options:nil] lastObject];
            _hudView.layer.cornerRadius = 9.0f;
    }
    return _hudView;
}

-(void)showHUDWithCaption:(NSString *)caption;
{
    [self.hudView displayHUDWithCaption:caption onView:[UIApplication sharedApplication].keyWindow];
}

-(void)flashHUDWithCaption:(NSString *)caption andImage:(UIImage *)image forDuration:(CGFloat)duration
{
    if (![NSThread isMainThread]) {
        NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(flashHUDWithCaption:andImage:forDuration:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:@selector(flashHUDWithCaption:andImage:forDuration:)];
        [invocation setTarget:self];
        [invocation setArgument:&caption atIndex:2];
        [invocation setArgument:&image atIndex:3];
        [invocation setArgument:&duration atIndex:4];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self.hudView displayHUDWithCaption:caption withImage:image onView:[UIApplication sharedApplication].keyWindow];
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:duration];

}

-(void)updateHUDWithCaption:(NSString *)caption andImage:(UIImage *)image
{
    if (![NSThread isMainThread]) {
       NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(updateHUDWithCaption:andImage:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:@selector(updateHUDWithCaption:andImage:)];
        [invocation setTarget:self];
        [invocation setArgument:&caption atIndex:2];
        [invocation setArgument:&image atIndex:3];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self.hudView.activityIndicator stopAnimating];
    self.hudView.hudLabel.text = caption;
    [self.hudView.imageView setImage:image];
    [self.hudView.imageView fadeInWithDuration:0.15f alpha:1.0f];
    
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:0.55f];
    
}

-(void)updateHUDWithCaption:(NSString *)caption success:(BOOL)success
{
    if (success) {
        [self updateHUDWithCaption:caption andImage:[UIImage imageNamed:@"checkmark.png"]];
    }else {
        [self updateHUDWithCaption:caption andImage:[UIImage imageNamed:@"failure.png"]];
    }
    
}

-(void)updateHUDWithCaption:(NSString *)caption
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateHUDWithCaption:) withObject:caption waitUntilDone:NO];
        return;
    }
    
    self.hudView.hudLabel.text = caption;
}

-(void)dismissHUDOnly
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(dismissHUDOnly) withObject:nil waitUntilDone:NO];
        return;
    }
    [self.hudView hideHUD];
}

-(void)dismissHUD
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(dismissHUD) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [[KPLightBoxManager sharedInstance] dismissLightBox];
    [self.hudView hideHUD];
}

@end
