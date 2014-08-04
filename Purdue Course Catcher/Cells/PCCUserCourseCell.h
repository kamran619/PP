//
//  PCCUserCourseCellTableViewCell.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/4/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCUserCourseCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel *courseTitle;
@property(nonatomic, strong) IBOutlet UILabel *credit;
@property(nonatomic, strong) IBOutlet UILabel *type;

@end
