//
//  Helpers.h
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 8/4/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERVER_ADDRESS @"127.0.0.1"
#define PORT 12345
@interface Helpers : NSObject


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

@end
