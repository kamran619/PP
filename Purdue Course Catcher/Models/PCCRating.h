//
//  PCCRating.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/19/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

enum RatingType
{
    RatingTypeProfessor = 0,
    RatingTypeCourse
} typedef RatingType;

@interface PCCRating : NSObject

@property (nonatomic, assign) RatingType type;

-(id)initWithRatingType:(RatingType)type;

@end
