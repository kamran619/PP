//
//  PCCScheduleCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/21/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCScheduleCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *startTime;
@property (nonatomic, strong) IBOutlet UILabel *endTime;

@property (nonatomic, strong) IBOutlet UILabel *location;

@property (nonatomic, strong) IBOutlet UILabel *courseName;
@property (nonatomic, strong) IBOutlet UILabel *courseTitle;

@property (nonatomic, strong) IBOutlet UILabel *courseSection;
@property (nonatomic, strong) IBOutlet UILabel *courseType;
@property (nonatomic, strong) IBOutlet UILabel *date;


@property (nonatomic, strong) IBOutlet UILabel *contentDivider;
@property (nonatomic, strong) IBOutlet UILabel *timeDivider;

@end
