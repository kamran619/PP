//
//  PCCProfessorRating.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/19/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCProfessorRating.h"

@implementation PCCProfessorRating

-(id)initWithName:(NSString *)name rating:(int)rating numberOfRatings:(int)numberOfRatings
{
    if (self = [super initWithRatingType:RatingTypeProfessor]) {
        self.name = name;
        self.rating = rating;
        self.numberOfRatings = numberOfRatings;
    }
    
    return self;
}
@end
