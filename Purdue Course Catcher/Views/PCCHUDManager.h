//
//  PCCHUDManager.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCCHUDView;

@interface PCCHUDManager : NSObject

+(id)sharedInstance;
-(void)showHUDWithCaption:(NSString *)caption;
-(void)updateHUDWithCaption:(NSString *)caption andImage:(UIImage *)image;
-(void)flashHUDWithCaption:(NSString *)caption andImage:(UIImage *)image forDuration:(CGFloat)duration;
-(void)updateHUDWithCaption:(NSString *)caption success:(BOOL)success;
-(void)dismissHUD;
-(void)dismissHUDOnly;

@property (nonatomic, strong) PCCHUDView *hudView;
@end
