//
//  PCCScheduleViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCScheduleHeaderViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "PCCTermViewController.h"
#import <MessageUI/MessageUI.h>

@interface PCCScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PCCScheduleHeaderDelegate, EGORefreshTableHeaderDelegate, UIGestureRecognizerDelegate, PCCTermDelegate, UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *termButton;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UINavigationController *termVC;
@property (nonatomic, strong) NSDictionary *responseDictionary;
@end
