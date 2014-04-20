//
//  PCCRating.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/19/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRating.h"

@implementation PCCRating

-(id)initWithRatingType:(RatingType)type
{
    if (self = [super init]) {
       self.type = type;
    }
    
    return self;
}

@end
