//
//  PCFSemester.m
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 10/31/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import "PCCObject.h"

@implementation PCCObject

NSString *const kEncodeKey = @"kEncodeKey";
NSString *const kEncodeValue = @"kEncodeValue";

-(id)initWithKey:(NSString *)key AndValue:(NSString *)value
{
    if (self = [super init]) {
        self.key = key;
        self.value = value;
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.key = [aDecoder decodeObjectForKey:kEncodeKey];
        self.value = [aDecoder decodeObjectForKey:kEncodeValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:kEncodeKey];
    [aCoder encodeObject:self.value forKey:kEncodeValue];
}

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        PCCObject *obj2 = (PCCObject *)object;
        if ([self.key isEqualToString:obj2.key] && [self.value isEqualToString:obj2.value]) return YES;
    }
    return NO;
}

-(NSComparisonResult)compare:(id)object {
    PCCObject *obj = (PCCObject *)object;
    return [self.value compare:obj.value];
}

@end
