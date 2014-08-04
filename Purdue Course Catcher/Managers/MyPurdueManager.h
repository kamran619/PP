//
//  MyPurdueManager.h
//  PurdueLogin
//
//  Created by Kamran Pirwani on 10/10/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Helpers.h"

@class PCCCourseSlots, PCCObject;

@interface MyPurdueManager : NSObject <NSURLConnectionDelegate, UIAlertViewDelegate>

+ (instancetype)sharedInstance;

//user specific data
-(BOOL)loginWithUsername:(NSString *)username andPassword:(NSString *)pass;
-(void)loginWithSuccessBlock:(void(^)())success andFailure:(void(^)())failure;

-(NSString *)getPinForSemester:(NSString *)semester;
//for registration
-(NSString *)generateQueryString:(NSArray *)currentCourses andRegisteringCourses:(NSArray *)registeringCourses andDroppingCourses:(NSArray *)droppingCourses;

-(NSDictionary *)getStudentInformation;

-(NSArray *)getCurrentScheduleViaWeekAtAGlance;
-(NSArray *)getCurrentScheduleViaConciseSchedule;
-(NSArray *)getCurrentScheduleViaConciseScheduleWithTerm:(PCCObject *)term;
-(NSArray *)getCurrentScheduleViaDetailSchedule;
-(NSArray *)getCurrentScheduleViaDetailScheduleWithTerm:(PCCObject *)term;


+(NSArray *)getTerms;
+(NSArray *)getMinimalTerms;

-(NSArray *)getRegistrationTerms;
-(NSDictionary *)canRegisterForTerm:(NSString *)term withPin:(NSString *)pin;
-(NSDictionary *)submitRegistrationChanges:(NSString *)query;

+(NSArray *)getCoursesForTerm:(NSString *)term WithClassName:(NSString *)className AndCourseNumber:(NSString *)courseNumber;
+(NSArray *)getCoursesForTerm:(NSString *)term WithCRN:(NSString *)CRN;
+(NSArray *)getCoursesWithParametersForTerm:(NSString *)term WithClassName:(NSString *)className AndCourseNumber:(NSString *)courseNumber AndSubject:(NSString *)subject FromHours:(NSString *)fromHours ToHours:(NSString *)toHours AndProfessor:(NSString *)professor AndDays:(NSString *)days scheduleType:(NSString *)scheduleType;

+(NSArray *)getSubjectsAndProfessorsForTerm:(NSString *)term;
+(NSArray *)getSubjectsForTerm:(NSString *)term;
+(NSArray *)getProfessorsForTerm:(NSString *)term;

+(NSString *)getCatalogInformationWithLink:(NSString *)catalogLink;
+(PCCCourseSlots *)getCourseAvailabilityWithLink:(NSString *)courseLink;
@end
