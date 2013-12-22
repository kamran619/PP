//
//  Course.h
//  PurdueLogin
//
//  Created by Kamran Pirwani on 9/16/13.
//  Copyright (c) 2013 kpirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Course : NSObject

@property (nonatomic, strong) NSString *course;
@property (nonatomic, strong) NSString *crn;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *link;

-(id)initWithCourse:(NSString *)course crn:(NSString *)crn time:(NSString *)time location:(NSString *)location link:(NSString *)link;

@end
