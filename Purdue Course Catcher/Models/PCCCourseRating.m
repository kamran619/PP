//
//  PCCCourseRating.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/19/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCCourseRating.h"

@implementation PCCCourseRating

-(id)initWithSubject:(NSString *)subject courseNumber:(int)courseNumber rating:(int)rating numberOfRatings:(int)numberOfRatings title:(NSString *)title
{
    if (self = [super initWithRatingType:RatingTypeCourse]) {
        self.subject = subject;
        self.courseNumber = courseNumber;
        self.rating = rating;
        self.numberOfRatings = numberOfRatings;
        self.title = title;
    }
    
    return self;
}
@end
