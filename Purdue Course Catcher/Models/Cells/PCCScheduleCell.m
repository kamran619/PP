//
//  PCCScheduleCell.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/21/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCScheduleCell.h"

#define CUSTOM_COLOR [UIColor colorWithRed:0.85031 green:0.239408 blue:0.283582 alpha:1.0f];

@implementation PCCScheduleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.contentDivider.backgroundColor = [UIColor blackColor];
    self.timeDivider.backgroundColor = CUSTOM_COLOR
}

@end
