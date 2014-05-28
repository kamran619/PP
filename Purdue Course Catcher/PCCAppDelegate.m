//
//  PCCAppDelegate.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCAppDelegate.h"
#import "PCCMenuViewController.h"
#import "PCCDataManager.h"
#import "PCFNetworkManager.h"
#import "Helpers.h"
#import "PCCFTUEViewController.h"
#import "PCCFacebookLoginViewController.h"
#import "PCCHUDManager.h"
#import "PCCCatcherViewController.h"
#import "PCCTabBarController.h"
#import "PCCSearchViewController.h"
#import "MyPurdueManager.h"
#import "Helpers.h"

@implementation PCCAppDelegate

-(void)customizeLook
{
    [[UIBarButtonItem appearanceWhenContainedIn:[PCCSearchViewController class], nil] setTintColor:[Helpers purdueColor:PurdueColorLightPink]];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //
    [[UITextField appearance] setTintColor:[UIColor blackColor]];

    //register for PN
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    //connect to server
    [PCFNetworkManager sharedInstance];
    
    //&& !(FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    //we don't care about the fb state anymore
    
    if ([Helpers hasRanAppBefore] == NO) {
        self.window.rootViewController = [[PCCFTUEViewController alloc] initWithNibName:@"PCCFTUEViewController" bundle:nil];
    }else {
        
        if (launchOptions)
        {
            launchOptions = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            UINavigationController *controller = (UINavigationController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCCatcher"];
            PCCCatcherViewController *vc = [controller.childViewControllers lastObject];
            [vc setDataSource:[PCCDataManager sharedInstance].arrayBasket.copy];
            PCCMenuViewController *menuVC  = [[PCCMenuViewController alloc] initCentralViewControllerWithViewController:controller];
            self.window.rootViewController = menuVC;
            application.applicationIconBadgeNumber = 0;
            return YES;
        }
        
        id delegate =  [UIApplication sharedApplication].delegate;
        [delegate openSession];
        //load the menu and other things
        self.window.rootViewController = [Helpers viewControllerWithStoryboardIdentifier:@"PCCTabBar"];
        //NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"agarwa28", kUsername, @"anuradha12", kPassword, nil];
        //[[PCCDataManager sharedInstance] setObject:dictionary ForKey:kCredentials InDictionary:DataDictionaryUser];
        //[[PCCTabBarController alloc] initWithNibName:@"PCCTabBarController" bundle:nil];
        //[[PCCMenuViewController alloc] initCentralViewControllerWithIdentifier:@"PCCSearch"];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[PCCDataManager sharedInstance] saveData];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

    /*if (launchOptions)
    {
        launchOptions = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        UINavigationController *controller = (UINavigationController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCCatcher"];
        PCCCatcherViewController *vc = [controller.childViewControllers lastObject];
        [vc setDataSource:[PCCDataManager sharedInstance].arrayBasket.copy];
        PCCMenuViewController *menuVC  = [[PCCMenuViewController alloc] initCentralViewControllerWithViewController:controller];
        self.window.rootViewController = menuVC;
        application.applicationIconBadgeNumber = 0;
}*/

}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *storedToken = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kDeviceToken];
    if ([storedToken isEqualToString:token]) return;
    
    [[PCCDataManager sharedInstance] setObject:token ForKey:kDeviceToken InDictionary:DataDictionaryUser];
    //send back to server if changed and we have already initted
    if ([Helpers getInitialization] == YES) {
        //lets update our server as the device token has changed
        [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandUpdate withDictionary:nil];
    }
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
    NSString *storedToken = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kDeviceToken];
    if (!storedToken) [[PCCDataManager sharedInstance] setObject:@"simulator_token" ForKey:kDeviceToken InDictionary:DataDictionaryUser];
}



#pragma mark FB Interaction
-(void) openSession
{
    
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"user_education_history", @"friends_about_me", @"friends_education_history"] allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        if (![Helpers hasRanAppBefore])  {
            //create settings dict for user
            [PCFNetworkManager sharedInstance].delegate = self;
            [Helpers requestFacebookIdentifier];
            //send fbid to server through notification
            [Helpers setHasRanAppBefore];
        }
    }
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [FBSession.activeSession closeAndClearTokenInformation];
        if ([PCCFacebookLoginViewController sharedInstance].currentlyDisplayed == NO) [self.window.rootViewController presentViewController:[PCCFacebookLoginViewController sharedInstance] animated:YES completion:nil];
    }
    
    // Handle errors
    if (error){
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Failed" success:NO];
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        if ([PCCFacebookLoginViewController sharedInstance].currentlyDisplayed == NO) [self.window.rootViewController presentViewController:[PCCFacebookLoginViewController sharedInstance] animated:YES completion:nil];
    }
}

-(void)showMessage:(NSString *)alertText withTitle:(NSString *)alertTitle
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertTitle delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

#pragma mark PCFNetwork Delegate
-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success
{
    int command;
    NSString *str;
    if (requestDictionary) {
        str = [requestDictionary objectForKey:@"command"];
    }else if (responseDictionary) {
        str = [responseDictionary objectForKey:@"command"];
    }
    
    command = str.intValue;
    if (command != ServerCommandInitialization) return;
    if (success) {
        [Helpers setInitialization];
        //mark initialization as successful
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Logged In..." success:YES];
        
        if ([self.window.rootViewController isKindOfClass:[PCCFTUEViewController class]]) {
            //if the root vc is the ftue, this is the first time lauching the app
            //we should dismiss the ftue view and show the menu
            //PCCMenuViewController *menu = [[PCCMenuViewController alloc] initCentralViewControllerWithIdentifier:@"PCCSearch"];
            //this was not presented..replace it with ours
            /*[UIView transitionFromView:self.window.rootViewController.view
                                toView:menu.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            completion:^(BOOL finished)
             {
                 if (finished) self.window.rootViewController = menu;
             }];*/
            self.window.rootViewController = [Helpers viewControllerWithStoryboardIdentifier:@"PCCTabBar"];
        }else {
            //the fb controller was displayed..minimize it
            [[PCCFacebookLoginViewController sharedInstance] dismissViewControllerAnimated:YES completion:nil];
        }
    }else {
        NSLog(@"Hit error statement");
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Error!" success:NO];
    }
}
@end
