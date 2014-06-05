//
//  PCCPurdueLoginViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCPurdueLoginViewController.h"
#import "PCCHUDManager.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCDataManager.h"
#import "PCCTabBarController.h"
#import "PCFNetworkManager.h"

@interface PCCPurdueLoginViewController ()
{
    BOOL loginSuccessfull;
}
@end

@implementation PCCPurdueLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loginSuccessfull = NO;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:self.tapGesture];
}

-(void)tapped:(id)sender
{
    [self.tableView endEditing:YES];
}

/*- (void)moveControls:(direction)direction animated:(BOOL)animated
{
    CGAffineTransform t;
    if (direction == directionDown) {
        t = CGAffineTransformMakeTranslation(0, 190);
    }else if (direction == directionUp) {
        t = CGAffineTransformIdentity;
    }
    
    if (animated) {
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.buttonWhy.transform = t;
            self.becauseLabel.transform = t;
        } completion:^(BOOL finished) {
            
        }];
    }else {
        self.buttonWhy.transform = t;
        self.becauseLabel.transform = t;
    }
}*/

- (IBAction)dismissPressed:(id)sender {
    //MyPurdueManager will send data once we get it
    /*if (loginSuccessfull == YES) {
        [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandUpdate withDictionary:nil];
    }*/

    [self dismissViewControllerAnimated:YES completion:nil];
}

/*-(IBAction)whyPressed:(id)sender
{
    if (CGAffineTransformEqualToTransform(self.buttonWhy.transform, CGAffineTransformIdentity)) {
        //its moved up.move it down
        [self moveControls:directionDown animated:YES];
    }else {
        [self moveControls:directionUp animated:YES];
    }
}
*/

-(IBAction)verifyPressed:(id)sender
{
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Verifying..."];
    
    [Helpers asyncronousBlockWithName:@"Check login credentials" AndBlock:^{
        BOOL success = [[MyPurdueManager sharedInstance] loginWithUsername:self.username.textField.text andPassword:self.password.textField.text];
        if (success) {
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Logged in..." success:YES];
                [Helpers setCurrentUser:self.username.textField.text];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.username.textField.text, kUsername, self.password.textField.text, kPassword, nil];
                [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kCredentials InDictionary:DataDictionaryUser];
                loginSuccessfull = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(dismissPressed:) withObject:nil afterDelay:0.25];
                });
            
        }else {
            loginSuccessfull = NO;
            [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Failed" success:NO];
        }
    }];
}

/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
*/
@end
