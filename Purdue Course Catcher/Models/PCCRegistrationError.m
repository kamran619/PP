//
//  PCCRegistrationError.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/26/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRegistrationError.h"

@implementation PCCRegistrationError

-(id)initWithErrorMessage:(NSString *)message crn:(NSString *)crn course:(NSString *)course
{
    if (self = [super init]) {
        self.message = message;
        self.crn = crn;
        self.course = course;
    }
    
    return self;
}
@end
