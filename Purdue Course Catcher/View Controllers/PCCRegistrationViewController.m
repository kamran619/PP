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
    
    if (!registrationTerm) {
        [self showTerms:nil];
    }else {
        self.registrationHeader = [[PCCHeaderViewController alloc] initWithTerm:registrationTerm.value];
        [self.registrationHeader changeMessage:registrationTerm.key message:@"Logging into myPurdue" image:nil];
        [self.registrationHeader slideIn];
        [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
            BOOL canRegister = [[MyPurdueManager sharedInstance] canRegisterForTerm:registrationTerm.value];
            if (!canRegister) {
                [self.registrationHeader changeMessage:registrationTerm.key message:@"Cannot register at this time" image:@"failure.png"];
            }else {
                [self.registrationHeader changeMessage:registrationTerm.key message:@"Ready to register" image:@"checkmark.png"];
            }
            [self.registrationHeader dismissHeaderWithDuration:0.75f];
            NSLog(@"%d",canRegister);
        }andFailure:^{
            NSLog(@"Login failed");
        }];
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
