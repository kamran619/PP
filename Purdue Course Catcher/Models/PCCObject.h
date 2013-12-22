//
//  PCFSemester.h
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 10/31/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCObject : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

-(id)initWithKey:(NSString *)key AndValue:(NSString *)value;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;
@end
