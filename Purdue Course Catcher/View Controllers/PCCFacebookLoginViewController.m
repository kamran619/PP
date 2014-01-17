//
//  PCCFacebookLoginViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCFacebookLoginViewController.h"
#import "PCCAppDelegate.h"
#import "Helpers.h"
#import "PCCHUDManager.h"

@interface PCCFacebookLoginViewController ()

@end

@implementation PCCFacebookLoginViewController

static PCCFacebookLoginViewController *_sharedInstance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = (PCCFacebookLoginViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCFacebookLogin"];
    });
    
    return _sharedInstance;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentlyDisplayed = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginButton.layer.cornerRadius = 9.0f;
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.currentlyDisplayed = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.currentlyDisplayed = NO;
}

- (IBAction)loginPushed:(id)sender {
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Logging in..."];
        // If the session state is any of the two "open" states when the button is clicked
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for basic_info permissions when opening a session
            [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 
                 // Retrieve the app delegate
                 PCCAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [appDelegate sessionStateChanged:session state:state error:error];
             }];
        }
        //PCCAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //[delegate openSession];
}

@end
