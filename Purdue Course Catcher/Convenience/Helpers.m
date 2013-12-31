//
//  Helpers.m
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 8/4/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers

+(BOOL)isiPhone
{
    return ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone);
}

+(BOOL)isIpad
{
     return ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad);
}

+(BOOL)hasTallScreenSize
{
    return [[UIScreen mainScreen] bounds].size.height == 568;
}

+(BOOL)isPhone5
{
    return [[self class] isiPhone] && [[self class] hasTallScreenSize];
}

#define FIRST_TIME_RUNNING_APP @"first_time_running_app"
+(BOOL)hasRanAppBefore
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:FIRST_TIME_RUNNING_APP];
}

+(void)setHasRanAppBefore
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FIRST_TIME_RUNNING_APP];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Easy Block Use
+(void)asyncronousBlockWithName:(NSString *)name AndBlock:(void (^)())block
{
    dispatch_queue_t queue = dispatch_queue_create(name.UTF8String, 0);
    dispatch_async(queue, block);
}

+(NSArray *)splitDate:(NSString *)date
{
    if ([date isEqualToString:@"TBA"]) return nil;
    NSArray *time = [date componentsSeparatedByString:@"-"];
    NSString *timeOne = [time objectAtIndex:0];
    NSString *timeTwo = [time objectAtIndex:1];
    NSArray *arr = [NSArray arrayWithObjects:timeOne, timeTwo, nil];
    return arr;
}


+(NSArray *)splitTime:(NSString *)time
{
    if ([time isEqualToString:@"TBA"]) {
        return [NSArray arrayWithObjects:@"TBA", @"TBA", nil];
    }
    NSArray *timeArray = [time componentsSeparatedByString:@"-"];
    NSString *timeOne = [[timeArray objectAtIndex:0] uppercaseString];
    NSString *timeTwo = [[timeArray objectAtIndex:1] uppercaseString];
    NSArray *arr = [NSArray arrayWithObjects:timeOne, timeTwo, nil];
    return arr;
}

+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    return [date compare:firstDate] == NSOrderedDescending &&
    [date compare:lastDate]  == NSOrderedAscending;
}

@end

