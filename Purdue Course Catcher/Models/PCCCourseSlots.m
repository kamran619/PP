//
//  PCFCourseRecord.m
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 11/1/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import "PCCCourseSlots.h"

@implementation PCCCourseSlots

-(id)initWithCapacity:(NSString *)capacity enrolled:(NSString *)enrolled remaining:(NSString *)remaining
{
    if (self = [super init]) {
        self.capacity = capacity;
        self.enrolled = enrolled;
        self.remaining = remaining;
    }
    
    return self;
}

@end
