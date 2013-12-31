//
//  PCCSearchResultsCell.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchResultsCell.h"

@implementation PCCSearchResultsCell


#define CUSTOM_COLOR [UIColor colorWithRed:0.85031 green:0.239408 blue:0.283582 alpha:1.0f];

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
    self.contentDivider.backgroundColor = [UIColor blackColor];
    self.timeDivider.backgroundColor = CUSTOM_COLOR
}

- (IBAction)actionButtonPressed:(id)sender {
    
}

- (IBAction)emailButtonPressed:(id)sender {
}


- (IBAction)ratingButtonPressed:(id)sender {
}

- (IBAction)catalogButtonPressed:(id)sender {
}

-(void)setupCatcher
{
    [self.actionButton setEnabled:YES];
    [self.actionButton setTitle:@"Catch" forState:UIControlStateNormal];
    [UIView animateWithDuration:0.25f animations:^{
        self.actionButton.alpha = 1.0f;
        self.slots.alpha = 1.0f;
    }];
}

-(void)setupRegister
{
    [self.actionButton setTitle:@"Register" forState:UIControlStateNormal];
    [self.actionButton setEnabled:NO];
    [UIView animateWithDuration:0.25f animations:^{
        self.actionButton.alpha = 1.0f;
        self.slots.alpha = 1.0f;
    }];
}
@end
