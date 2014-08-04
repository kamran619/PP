//
//  PCCAddRatingChooseSemesterViewController.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCRating.h"

@interface PCCAddRatingChooseSemesterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, assign) RatingType type;
@end
