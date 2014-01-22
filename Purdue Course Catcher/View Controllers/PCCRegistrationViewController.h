//
//  PCCRegistrationViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/20/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCTermViewController.h"
#import "PCCHeaderViewController.h"

@interface PCCRegistrationViewController : UIViewController <PCCTermDelegate>

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) PCCHeaderViewController *registrationHeader;

@end
