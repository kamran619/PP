//
//  PCCNicknameCellTableViewCell.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/15/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCNicknameTableViewCell.h"

@implementation PCCNicknameTableViewCell

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


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];// this will do the trick
}


@end
