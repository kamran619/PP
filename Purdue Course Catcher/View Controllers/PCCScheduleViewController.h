//
//  PCCScheduleViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *setupContainerView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *buttonNext;

@property (nonatomic, strong) IBOutlet UIView *containerViewForSchedule;

@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
