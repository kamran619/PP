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
#import "PCCSideMenuViewController.h"
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
    [self moveControls:directionDown animated:NO];
    self.becauseLabel.hidden = NO;
	// Do any additional setup after loading the view.
}

- (void)moveControls:(direction)direction animated:(BOOL)animated
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
}
- (IBAction)dismissPressed:(id)sender {
    PCCMenuViewController *vc = (PCCMenuViewController*)[self presentingViewController];
    if (loginSuccessfull == YES) {
        [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandUpdate withDictionary:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (loginSuccessfull == YES) {
            PCCSideMenuViewController *menu = (PCCSideMenuViewController *)[vc leftViewController];
            [menu menuItemPressed:@"Schedule"];
        }
    }];
}

-(IBAction)whyPressed:(id)sender
{
    if (CGAffineTransformEqualToTransform(self.buttonWhy.transform, CGAffineTransformIdentity)) {
        //its moved up.move it down
        [self moveControls:directionDown animated:YES];
    }else {
        [self moveControls:directionUp animated:YES];
    }
}


-(IBAction)verifyPressed:(id)sender
{
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Verifying..."];
    
    [Helpers asyncronousBlockWithName:@"Check login credentials" AndBlock:^{
        BOOL success = [[MyPurdueManager sharedInstance] loginWithUsername:self.username.text andPassword:self.password.text];
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Complete" success:YES];
                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.username.text, kUsername, self.password.text, kPassword, nil];
                [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kCredentials InDictionary:DataDictionaryUser];
                loginSuccessfull = YES;
                [self dismissPressed:nil];
            });
        } else {
            loginSuccessfull = NO;
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
