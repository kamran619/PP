//
//  PCCHUDView.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCHUDView : UIView

-(void)displayHUDWithCaption:(NSString *)caption withImage:(UIImage *)image onView:(UIView *)view;
-(void)displayHUDWithCaption:(NSString *)caption onView:(UIView *)view;
-(void)hideHUD;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *hudLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@end
