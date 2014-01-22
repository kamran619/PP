//
//  PCCRegistrationViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/20/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRegistrationViewController.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCDataManager.h"
#import "PCCObject.h"
#import "PCCTermViewController.h"
#import "UIView+Animations.h"

@interface PCCRegistrationViewController ()

@end

@implementation PCCRegistrationViewController
{

}
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
	// Do any additional setup after loading the view.
    [self checkRegistration];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)checkRegistration
{
    PCCObject *registrationTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredRegistrationTerm];
    
    void (^success)() = ^{
        [self.registrationHeader changeMessage:registrationTerm.key message:@"Logged in! Verifying pin..." image:nil];
        [Helpers asyncronousBlockWithName:@"Check valid pin" AndBlock:^{
            PCCError canRegister = [[MyPurdueManager sharedInstance] canRegisterForTerm:registrationTerm.value];
            if (canRegister == PCCErrorInvalidPin || canRegister == PCCErrorUnkownError) {
                [self.registrationHeader changeMessage:registrationTerm.key message:@"Invalid pin" image:@"failure.png"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect PIN" message:[NSString stringWithFormat:@"Please enter a correct PIN for %@", registrationTerm.key] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [alertView show];
                });
            }else if (canRegister == PCCErrorOk) {
                [self.registrationHeader changeMessage:registrationTerm.key message:@"Ready to register" image:@"checkmark.png"];
            }
            [self.registrationHeader dismissHeaderWithDuration:0.75f];
            NSLog(@"%d",canRegister);
        }];
    };
    
    if (!registrationTerm) {
        [self showTerms:nil];
    }else {
        if (!self.registrationHeader) self.registrationHeader = [[PCCHeaderViewController alloc] initWithTerm:registrationTerm.value];
        [self.registrationHeader changeMessage:registrationTerm.key message:@"Logging into myPurdue" image:nil];
        [self.registrationHeader slideIn:self.view];
        [[MyPurdueManager sharedInstance] loginWithSuccessBlock:success andFailure:^{
            [self.registrationHeader changeMessage:registrationTerm.key message:@"Error logging into myPurdue" image:@"failure.png"];
        }];
    }
    
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (textField.text.length > 0) {
        NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
        if (!dictionary) dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
            PCCObject *registrationTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredRegistrationTerm];
        [dictionary setObject:textField.text forKey:registrationTerm.value];
        [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kPinDictionary InDictionary:DataDictionaryUser];
        [self checkRegistration];
    }
}

-(void)termPressed:(PCCObject *)term
{
    [[PCCDataManager sharedInstance] setObject:term ForKey:kPreferredRegistrationTerm InDictionary:DataDictionaryUser];
    [self checkRegistration];
}

-(IBAction)showTerms:(id)sender
{
    if (!self.navController) {
        self.navController = (UINavigationController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCTerm"];
        PCCTermViewController *termVC = [self.navController.childViewControllers lastObject];
        [termVC setType:PCCTermTypeRegistration];
        [termVC setDelgate:self];
    }
    
    [self presentViewController:self.navController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
