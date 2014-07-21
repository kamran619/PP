//
//  PCCNotificationViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 7/6/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCNotificationViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Helpers.h"
#import "KPLightBoxManager.h"
#import "KPNotificationCenter.h"

@interface PCCNotificationViewController ()

@end

@implementation PCCNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

-(instancetype) initWithTitle:(NSString *)title andMessage:(NSString *)message andLeftButton:(NSString *)leftButtonText andRightButton:(NSString *)rightButtonText
{
    if (self = [super init]) {
        [self view];
        self.notificationTitle.text = title;
        self.notificationMessage.text = message;
        self.leftButton.titleLabel.text = leftButtonText;
        self.rightButton.titleLabel.text = rightButtonText;
    }
    
    return self;
    
}

-(void)presentNotificationOnView:(UIView *)view
{
    [self presentNotificationOnView:view withBlock:nil];
}

-(void)presentNotificationOnView:(UIView *)view withBlock:(void (^)())block
{
    CGSize windowSize = [[UIApplication sharedApplication].delegate window].frame.size;
    CGSize ourCurrentSize = self.view.frame.size;
    CGRect center = CGRectMake((windowSize.width - self.view.frame.size.width)/2, windowSize.height/2 - self.view.frame.size.height/2, ourCurrentSize.width, ourCurrentSize.height);
    [self.view setFrame:center];
    self.view.layer.transform = CATransform3DMakeScale(0.001, 0.001, .001);
    self.leftButton.alpha = 0.0f;
    self.rightButton.alpha = 0.0f;
    [view addSubview:self.view];
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:.9f initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.leftButton.alpha = 1.0f;
        self.leftButton.layer.transform = CATransform3DMakeScale(1.02, 1.02, 1);
        self.rightButton.layer.transform = CATransform3DMakeScale(1.02, 1.02, 1);
        self.rightButton.alpha = 1.0f;
        self.view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    }completion:^(BOOL finished) {
        if (finished) {
        
        }
    }];
}

-(void)hideNotification
{
    [self hideNotificationWithBlock:nil];
}

-(void)hideNotificationWithBlock:(void (^)())block
{
    [UIView animateWithDuration:0.4f delay:0.0f usingSpringWithDamping:0.4f initialSpringVelocity:5.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5);
        self.view.alpha = 0.0f;
    }completion:^(BOOL finished) {
        if (finished) {
            [self.view removeFromSuperview];
            [[KPNotificationCenter sharedInstance] removeNotification:self];
            if (block) {
                block();
            }
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.layer.cornerRadius = 8.0f;
    self.view.layer.borderColor = [Helpers purdueColor:PurdueColorLightGrey].CGColor;
    self.view.layer.borderWidth = 1.5f;
    self.leftButton.layer.cornerRadius = 4.0f;
    self.rightButton.layer.cornerRadius = 4.0f;
    [self.leftButton addTarget:self action:@selector(leftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)leftButtonTapped:(UIButton *)button
{
    if (self.leftButtonCompletionBlock)  {
        BOOL result = self.leftButtonCompletionBlock();
        if (result) [self hideNotification];
    }
}

-(void)rightButtonTapped:(UIButton *)button
{
    if (self.rightButtonCompletionBlock) {
        BOOL result = self.rightButtonCompletionBlock();
        if (result) [self hideNotification];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
