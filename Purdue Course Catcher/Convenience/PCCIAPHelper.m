//
//  PCCIAPHelper.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/10/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCIAPHelper.h"

@implementation PCCIAPHelper

+ (PCCIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static PCCIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.kamranpirwani.pcc.removeads",
                                      @"com.kamranpirwani.pcc.gopro",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
