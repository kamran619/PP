 //
//  KPSegue.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "KPSegue.h"

@implementation KPSegue
-(void)perform
{
    [[self sourceViewController] presentViewController:self.destinationViewController animated:YES completion:nil];
}

@end
