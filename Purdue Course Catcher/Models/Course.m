//
//  Course.m
//  PurdueLogin
//
//  Created by Kamran Pirwani on 9/16/13.
//  Copyright (c) 2013 kpirwani. All rights reserved.
//

#import "Course.h"

@implementation Course

-(id)initWithCourse:(NSString *)course crn:(NSString *)crn time:(NSString *)time location:(NSString *)location link:(NSString *)link
{
    self.course = course;
    self.crn = crn;
    self.time = time;
    self.location = location;
    self.link = link;
    return self;
}

-(BOOL)isEqual:(id)object
{
    Course *obj = (Course *)object;
    return [self.crn isEqualToString:obj.crn];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"Course: %@, CRN: %@, Time: %@, Location: %@, Link: %@\n", self.course, self.crn, self.time, self.location, self.link];
}
@end
