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
#import "MyPurdueManager.h"
#import <MessageUI/MessageUI.h>

@implementation Helpers

#pragma mark UI Colors

+(UIColor *)purdueColor:(enum PurdueColor)color alpha:(CGFloat)alpha
{
    UIColor *customColor;
    
    switch (color) {
        case PurdueColorYellow:
            customColor = [UIColor colorWithRed:.890f green:.6824f blue:.1411f alpha:alpha];
            break;
        case PurdueColorDarkGrey:
            customColor = [UIColor colorWithRed:.455f green:.4235f blue:.4f alpha:alpha];
            break;
            
        case PurdueColorMidGrey:
            //167 169 172
            customColor = [UIColor colorWithRed:.655f green:.6627f blue:.6745f alpha:alpha];
            break;
            
        case PurdueColorLightGrey:
            //209 211 212
            customColor = [UIColor colorWithRed:.8196f green:.8274f blue:.8314f alpha:alpha];
            break;
            
        case PurdueColorLightPink:
            //217,61,72
            customColor = [UIColor colorWithRed:.85098f green:.23921f blue:.28235 alpha:alpha];
            break;
            
        default:
            break;
    }
    
    return customColor;
}

+(UIColor *)purdueColor:(enum PurdueColor)color
{
    return [[self class] purdueColor:color alpha:1.0f];
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
                NSLog(@"%@", error.description);
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

+(NSArray *)getArrayOfScheduleTypes:(NSArray *)classes
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:2];
    for (PCFClassModel *class in classes) {
        [set addObject:class.scheduleType];
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithObject:@"All"];
    [array addObjectsFromArray:set.allObjects];
    return array.copy;
}

+(void)sendEmail:(PCFClassModel *)course forViewController:(UIViewController *)vc
{
    Class mailView = NSClassFromString(@"MFMailComposeViewController");
    if (mailView) {
        if ([mailView canSendMail]) {
            MFMailComposeViewController *mailSender = [[MFMailComposeViewController alloc] init];
            mailSender.mailComposeDelegate = vc;
            NSArray *toRecipient = [NSArray arrayWithObject:[course instructorEmail]];
            [mailSender setToRecipients:toRecipient];
            NSString *emailBody = [[NSString alloc] initWithFormat:@"Professor %@,\n", [course instructor]];
            [mailSender setMessageBody:emailBody isHTML:NO];
            [mailSender setSubject:[NSString stringWithFormat:@"%@: %@", course.courseNumber, course.classTitle]];
            [vc presentViewController:mailSender animated:YES completion:nil];
        }else {
            NSString *recipients = [[NSString alloc] initWithFormat:@"mailto:%@&subject=%@: %@", [course instructorEmail], [course courseNumber], course.classTitle];
            NSString *body = [[NSString alloc] initWithFormat:@"&body=Professor %@,\n", [course instructor]];
            NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }else {
        NSString *recipients = [[NSString alloc] initWithFormat:@"mailto:%@&subject=%@", [course instructorEmail], [course courseNumber]];
        NSString *body = [[NSString alloc] initWithFormat:@"&body=Professor %@,\n", [course instructor]];
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }

}

+(NSString *)getCurrentUser
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUser];
}

+(void)setCurrentUser:(NSString *)user
{
    if (!user) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentUser];
        [[PCCDataManager sharedInstance] loadData];
    }else  {
        NSString *oldUser = [[self class] getCurrentUser];
        if ([oldUser isEqualToString:user]) return;
        [[PCCDataManager sharedInstance] saveData];
        [[NSUserDefaults standardUserDefaults] setObject:user forKey:kCurrentUser];
        [[PCCDataManager sharedInstance] loadData];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (PCCObject *)termToPCCObject:(NSString *)term {
    NSArray *array = [term componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (array.count != 2) return nil;
    NSString *termName = array[0];
    NSString *year = array[1];
    
    NSString *finalTerm;
    int yearNum = [year intValue];
    if ([termName isEqualToString:@"Fall"]) {
        yearNum++;
        finalTerm = [NSString stringWithFormat:@"%d10", yearNum];
    }else if ([termName isEqualToString:@"Spring"]) {
        finalTerm = [NSString stringWithFormat:@"%d20", yearNum];
    }else if ([termName isEqualToString:@"Summer"]) {
        finalTerm = [NSString stringWithFormat:@"%d30", yearNum];
    }
    
    return [[PCCObject alloc] initWithKey:term AndValue:finalTerm];
}
@end

