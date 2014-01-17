//
//  PCCFacebookLoginViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCFacebookLoginViewController : UIViewController

+ (instancetype)sharedInstance;

@property (nonatomic, assign) BOOL currentlyDisplayed;
@property (nonatomic, strong) IBOutlet UIButton *loginButton;

@end
