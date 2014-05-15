//
//  Helpers.m
//  Purdue Course Sniper
//
//  Created by Kamran Pirwani on 8/4/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "Helpers.h"
#import "PCCDataManager.h"
#import "PCFNetworkManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PCFClassModel.h"

@implementation Helpers

#pragma mark UI Colors

+(UIColor *)purdueColor:(enum PurdueColor)color
{
    UIColor *customColor;
    
    switch (color) {
        case PurdueColorYellow:
            customColor = [UIColor colorWithRed:.890f green:.6824f blue:.1411f alpha:1.0f];
            break;
        case PurdueColorDarkGrey:
            customColor = [UIColor colorWithRed:.455f green:.4235f blue:.4f alpha:1.0f];
            break;
            
        case PurdueColorMidGrey:
            //167 169 172
            customColor = [UIColor colorWithRed:.655f green:.6627f blue:.6745f alpha:1.0f];
            break;
            
        case PurdueColorLightGrey:
            //209 211 212
            customColor = [UIColor colorWithRed:.8196f green:.8274f blue:.8314f alpha:1.0f];
            break;
            
        case PurdueColorLightPink:
            //217,61,72
            customColor = [UIColor colorWithRed:.85098f green:.23921f blue:.28235 alpha:1.0f];
            break;
            
        default:
            break;
    }
    
    return customColor;
}

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
    return (BOOL)[[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:FIRST_TIME_RUNNING_APP];
}

+(void)setHasRanAppBefore
{
    [[PCCDataManager sharedInstance] setObject:@YES ForKey:FIRST_TIME_RUNNING_APP InDictionary:DataDictionaryUser];
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

+(UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

+(void)requestFacebookIdentifier
{
    NSString *identifier = [[self class] getFacebookIdentifier];
    if (identifier) return;
    
    if ([FBSession.activeSession isOpen]) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary <FBGraphUser> *user, NSError *error) {
            if (!error) {
                [[PCCDataManager sharedInstance] setObject:user.id ForKey:kUserID InDictionary:DataDictionaryUser];
                /*creating user for the first time, let's get their name and save it as the nickname and name
                NSMutableDictionary *schoolInfo = [NSMutableDictionary dictionaryWithCapacity:3];
                [schoolInfo setObject:user.name forKey:kName];
                [[PCCDataManager sharedInstance] setObject:schoolInfo ForKey:kEducationInfoDictionary InDictionary:DataDictionaryUser];
                 */
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReceivedFTUEComplete object:[PCFNetworkManager sharedInstance] userInfo:user];
            }else {
                NSLog(@"Error getting fbid");
            }

        }];
    }
}

+(NSString *)getFacebookIdentifier
{
    NSString *identifier = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kUserID];
    return identifier;
}

+(BOOL)getInitialization
{
    NSNumber *number = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kInitialized];
    return number.intValue;
}

+(void)setInitialization
{
    //we have created an account on the server side
    [[PCCDataManager sharedInstance] setObject:[NSNumber numberWithInt:1] ForKey:kInitialized InDictionary:DataDictionaryUser];
}

+(NSDictionary *)getCredentials
{
    return [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kCredentials];
}

+(NSArray *)sortArrayUsingTime:(NSMutableArray *)array {
    return [array sortedArrayUsingComparator:^(id obj1, id obj2) {
        PCFClassModel *objectOne = (PCFClassModel *)obj1;
        PCFClassModel *objectTwo = (PCFClassModel *)obj2;
        NSArray *timeArrayOne = [Helpers splitTime:objectOne.time];
        NSArray *timeArrayTwo = [Helpers splitTime:objectTwo.time];
        
        NSInteger timeOneStart = [self getIntegerRepresentationOfTime:[timeArrayOne objectAtIndex:0]];
        NSInteger timeOneEnd = [self getIntegerRepresentationOfTime:[timeArrayOne objectAtIndex:1]];
        
        NSInteger timeTwoStart = [self getIntegerRepresentationOfTime:[timeArrayTwo objectAtIndex:0]];
        NSInteger timeTwoEnd = [self getIntegerRepresentationOfTime:[timeArrayTwo objectAtIndex:1]];
        
        if (timeOneStart < timeTwoStart) return (NSComparisonResult)NSOrderedAscending;
        if (timeOneStart > timeTwoStart) return (NSComparisonResult)NSOrderedDescending;
        
        //equal
        if (timeOneEnd < timeTwoEnd) {
            return NSOrderedAscending;
        }else if (timeOneEnd < timeTwoEnd) {
            return NSOrderedDescending;
        }else {
            return NSOrderedSame;
        }
    }];
}

+(NSInteger)getIntegerRepresentationOfTime:(NSString *)str {
    if ([str isEqualToString:@"TBA"]) return INFINITY;
    //str is 09:30 am
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    NSString *firstStringNumber, *secondStringNumber, *thirdStringNumber;
    NSInteger firstNumber = 0, secondNumber = 0, thirdNumber = 0;
    [scanner scanUpToString:@":" intoString:&firstStringNumber];
    [scanner setScanLocation:([scanner scanLocation] + 1)];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&secondStringNumber];
    [scanner setScanLocation:([scanner scanLocation] + 1)];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&thirdStringNumber];
    firstNumber = [firstStringNumber integerValue];
    secondNumber = [secondStringNumber integerValue];
    if ([thirdStringNumber isEqualToString:@"AM"]) {
        //am
        thirdNumber = 0;
    }else {
        //pm
        if (![firstStringNumber isEqualToString:@"12"]) thirdNumber = 720;
    }
    NSInteger intergerRepresentation = (firstNumber*60) + secondNumber + thirdNumber;
    return intergerRepresentation;
}

+(BOOL)isLoggedIn
{
    NSDictionary *credentials = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kCredentials];
    NSString *username = [credentials objectForKey:kUsername];
    NSString *password = [credentials objectForKey:kPassword];
    return username && password;
    
}

+(NSString *)getPUID
{
    NSDictionary *credentials = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kCredentials];
    NSString *username = [credentials objectForKey:kUsername];
    return username;
}

+(UIImage *)getImageForStars:(int)stars
{
    NSString *imgName = [NSString stringWithFormat:@"star-%d.png", stars];
    return [UIImage imageNamed:imgName];
    
}
@end

