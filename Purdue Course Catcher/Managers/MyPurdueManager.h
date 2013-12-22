//
//  MyPurdueManager.h
//  PurdueLogin
//
//  Created by Kamran Pirwani on 10/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFCourseRecord;

@interface MyPurdueManager : NSObject <NSURLConnectionDelegate>

+ (instancetype)sharedInstance;

//user specific data
-(BOOL)loginWithUsername:(NSString *)username andPassword:(NSString *)pass;

-(NSArray *)getCurrentScheduleViaWeekAtAGlance;
-(NSArray *)getCurrentScheduleViaConciseSchedule;
-(NSArray *)getCurrentScheduleViaDetailSchedule;

+(NSArray *)getTerms;
+(NSArray *)getMinimalTerms;

+(NSArray *)getCoursesForTerm:(NSString *)term WithClassName:(NSString *)className AndCourseNumber:(NSString *)courseNumber;
+(NSArray *)getCoursesForTerm:(NSString *)term WithCRN:(NSString *)CRN;
+(NSArray *)getCoursesWithParametersForTerm:(NSString *)term WithClassName:(NSString *)className AndCourseNumber:(NSString *)courseNumber AndSubject:(NSString *)subject FromHours:(NSString *)fromHours ToHours:(NSString *)toHours AndProfessor:(NSString *)professor AndDays:(NSString *)days;

+(NSArray *)getSubjectsAndProfessorsForTerm:(NSString *)term;
+(NSArray *)getSubjectsForTerm:(NSString *)term;
+(NSArray *)getProfessorsForTerm:(NSString *)term;

+(NSString *)getCatalogInformationWithLink:(NSString *)catalogLink;
+(PCFCourseRecord *)getCourseAvailabilityWithLink:(NSString *)courseLink;
@end