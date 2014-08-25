//
//  PCCProfessorRating.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/19/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRating.h"

@interface PCCProfessorRating : PCCRating

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int rating;
@property (nonatomic, assign) int numberOfRatings;

-(id)initWithName:(NSString *)name rating:(int)rating numberOfRatings:(int)numberOfRatings;

@end
