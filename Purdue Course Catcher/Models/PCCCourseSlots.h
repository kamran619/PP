//
//  PCFCourseRecord.h
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 11/1/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCCourseSlots : NSObject

@property (nonatomic, strong) NSString *capacity;
@property (nonatomic, strong) NSString *enrolled;
@property (nonatomic, strong) NSString *remaining;

-(id)initWithCapacity:(NSString *)capacity enrolled:(NSString *)enrolled remaining:(NSString *)remaining;
@end
