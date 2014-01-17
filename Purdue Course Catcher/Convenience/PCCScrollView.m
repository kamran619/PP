//
//  PCCScrollView.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCScrollView.h"

@implementation PCCScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self endEditing:YES];// this will do the trick
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
