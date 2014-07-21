//
//  PCCNotificationViewController.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 7/6/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCNotificationViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *notificationTitle;
@property (nonatomic, strong) IBOutlet UILabel *notificationMessage;
@property (nonatomic, strong) IBOutlet UIButton *leftButton;
@property (nonatomic, strong) IBOutlet UIButton *rightButton;

@property (nonatomic, copy) BOOL (^leftButtonCompletionBlock)();
@property (nonatomic, copy) BOOL (^rightButtonCompletionBlock)();

-(instancetype) initWithTitle:(NSString *)title andMessage:(NSString *)message andLeftButton:(NSString *)leftButtonText andRightButton:(NSString *)rightButtonText;

-(void)presentNotificationOnView:(UIView *)view;
-(void)hideNotification;

-(void)presentNotificationOnView:(UIView *)view withBlock:(void (^)())block;
-(void)hideNotificationWithBlock:(void (^)())block;

-(void)leftButtonTapped:(UIButton *)button;
-(void)rightButtonTapped:(UIButton *)button;

@end
