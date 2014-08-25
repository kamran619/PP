//
//  PCCGenericRating.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCGenericRating.h"

@implementation PCCGenericRating

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message andVariatons:(NSArray *)variations {
    if (self = [super init]) {
        self.title = title;
        self.message = message;
        self.variations = variations;
    }
    
    return self;
}

@end
