//
//  PCCCatcherCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/11/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCCatcherCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *courseTitle;
@property (nonatomic, strong) IBOutlet UILabel *courseNumber;
@property (nonatomic, strong) IBOutlet UILabel *slots;
@property (nonatomic, strong) IBOutlet UILabel *scheduleType;
@property (nonatomic, strong) IBOutlet UILabel *CRN;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
