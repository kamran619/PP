//
//  PCCGenericRating.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCGenericRating : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, strong) NSArray *variations;

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message andVariatons:(NSArray *)variations;
@end
