//
//  PCCRegistrationError.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/26/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCRegistrationError : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *crn;
@property (nonatomic, strong) NSString *course;

-(id)initWithErrorMessage:(NSString *)message crn:(NSString *)crn course:(NSString *)course;

@end
