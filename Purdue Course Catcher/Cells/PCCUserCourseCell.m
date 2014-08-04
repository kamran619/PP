//
//  PCCUserCourseCellTableViewCell.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/4/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCUserCourseCell.h"

@implementation PCCUserCourseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
