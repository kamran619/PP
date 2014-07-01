//
//  PCCCatcherViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "PCFNetworkManager.h"

@interface PCCCatcherViewController : UIViewController <UITableViewDataSource, UITableViewDataSource, EGORefreshTableHeaderDelegate, PCFNetworkDelegate>

@property (nonatomic, strong) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end
