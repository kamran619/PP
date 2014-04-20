//
//  PCCRatingsCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/17/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCCourseRatingsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *masterText;
@property (nonatomic, strong) IBOutlet UILabel *detailText;
@property (nonatomic, strong) IBOutlet UIImageView *stars;
@property (nonatomic, strong) IBOutlet UILabel *numberOfReviews;

@end
