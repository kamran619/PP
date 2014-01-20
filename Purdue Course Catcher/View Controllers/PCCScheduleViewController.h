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

@interface PCCScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, PCCScheduleHeaderDelegate, EGORefreshTableHeaderDelegate, UIGestureRecognizerDelegate, PCCTermDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UIView *containerViewForSchedule;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UINavigationController *termVC;
@end
