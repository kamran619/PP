//
//  PCCAppDelegate.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PCFNetworkManager.h"
@interface PCCAppDelegate : UIResponder <UIApplicationDelegate, PCFNetworkDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

//Facebook stuff
-(void)openSession;
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error;

@end
