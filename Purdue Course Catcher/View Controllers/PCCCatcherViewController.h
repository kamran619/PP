//
//  PCCCatcherViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@interface PCCCatcherViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end
