//
//  Helpers.h
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 8/4/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ADDRESS @"PCW.crabdance.com"
#define PORT 12345

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

#define kNotificationReceivedFacebookIdentifier @"kNotificationReceivedFacebookIdentifier"

@class PCFClassModel;

@interface Helpers : NSObject

enum direction
{
    directionUp = 0,
    directionDown = 1,
    directionLeft = 2,
    directionRight = 3
} typedef direction;

enum PCCError
{
    PCCErrorOk = 0,
    PCCErrorInvalidPin = 1,
    PCCErrorUnkownError = 2
} typedef PCCError;

enum search
{
    searchCourse = 0,
    searchCRN = 1,
    searchAdvanced = 2
} typedef search;

/*Get details of the type of devices we are working with */
+(BOOL)isiPhone;
+(BOOL)hasTallScreenSize;
+(BOOL)isIpad;

+(BOOL)isPhone5;

/*Get details about our app */
+(BOOL)hasRanAppBefore;
+(void)setHasRanAppBefore;

/*Quick Blocks*/
+(void)asyncronousBlockWithName:(NSString *)name AndBlock:(void (^)())block;

/*Scanner Operations */

/*Parse Date*/
+(NSArray *)splitDate:(NSString *)date;
+(NSArray *)splitTime:(NSString *)time;
+ (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate;
+(UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier;

+(NSString *)getFacebookIdentifier;

+(void)requestFacebookIdentifier;

+(BOOL)getInitialization;
+(void)setInitialization;
+(NSDictionary *)getCredentials;


+(NSInteger)getIntegerRepresentationOfTime:(NSString *)str;
+(NSArray *)sortArrayUsingTime:(NSMutableArray *)array;

+(BOOL)isLoggedIn;
@end
