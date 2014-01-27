//
//  PCFClassModel.h
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 10/29/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFClassModel : NSObject <NSCoding>


@property (nonatomic, copy) NSString *classTitle;
@property (nonatomic, copy) NSString *CRN;
@property (nonatomic, copy) NSString *courseNumber;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *days;
@property (nonatomic, copy) NSString *dateRange;
@property (nonatomic, copy) NSString *scheduleType;
@property (nonatomic, copy) NSString *classType;
@property (nonatomic, copy) NSString *instructor;
@property (nonatomic, copy) NSString *instructorEmail;
@property (nonatomic, copy) NSString *credits;
@property (nonatomic, copy) NSString *classLink;
@property (nonatomic, copy) NSString *catalogLink;
@property (nonatomic, copy) NSString *sectionNum;
@property (nonatomic, copy) NSString *classLocation;
@property (nonatomic, copy) NSString *linkedID;
@property (nonatomic, copy) NSString *linkedSection;

@property (nonatomic, copy) NSString *gradeMode;
@property (nonatomic, copy) NSString *level;
@property (nonatomic, copy) NSString *term;
@property (nonatomic, copy) NSString *startDate;
@property (nonatomic, copy) NSString *endDate;
@property (nonatomic, copy) NSString *status;

-(id)initWithClassTitle:(NSString *)classTitle crn:(NSString *)crn courseNumber:(NSString *)courseNumber Time:(NSString *)Time Days:(NSString *)Days DateRange:(NSString *)daterange ScheduleType:(NSString *)scheduletype Instructor:(NSString *)Instructor Credits:(NSString *)Credits ClassLink:(NSString *)ClassLink CatalogLink:(NSString *)CatalogLink SectionNum:(NSString *)SectionNum ClassLocation:(NSString *)ClassLocation Email:(NSString *)InstructorEmail linkedID:(NSString *)linkedID linkedSection:(NSString *)linkedSection;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end
