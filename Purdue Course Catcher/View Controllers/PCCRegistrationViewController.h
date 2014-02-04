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

@interface PCCRegistrationViewController : UIViewController <PCCTermDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) PCCHeaderViewController *registrationHeader;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;

@property (nonatomic, strong) void (^deletionBlock)(void);

@property (nonatomic, strong) NSString *queryString;

@property (nonatomic, strong) NSDictionary *responseDictionary;

@end
