//
//  PCCCourseRating.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/19/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRating.h"

@interface PCCCourseRating : PCCRating

@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) int courseNumber;
@property (nonatomic, assign) int rating;
@property (nonatomic, assign) int numberOfRatings;

-(id)initWithSubject:(NSString *)subject courseNumber:(int)courseNumber rating:(int)rating numberOfRatings:(int)numberOfRatings title:(NSString *)title;

@end
