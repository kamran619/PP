//
//  PCCRegistrationCell.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRegistrationDropCell.h"

@implementation PCCRegistrationDropCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)dropPressed:(id)sender {
    if ([self.dropButton tag] == 0) {
        [self.dropButton setTitle:@"Undrop" forState:UIControlStateNormal];
        [self.dropButton setTag:1];
    }else if ([self.dropButton tag] == 1) {
        [self.dropButton setTitle:@"Drop" forState:UIControlStateNormal];
        [self.dropButton setTag:0];
    }
}


@end
