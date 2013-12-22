//
//  PCFClassModel.m
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 10/29/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import "PCFClassModel.h"

NSString *const kEncodeClassTitle = @"kEncodeClassTitle";
NSString *const kEncodeCRN = @"kEncodeCRN";
NSString *const kEncodeCourseNumber = @"kEncodeCourseNumber";
NSString *const kEncodeTime = @"kEncodeTime";
NSString *const kEncodeDays = @"kEncodeDays";
NSString *const kEncodeDateRange = @"kEncodeDateRange";
NSString *const kEncodeClassType = @"kEncodeClassType";
NSString *const kEncodescheduleType = @"kEncodeScheduleType";
NSString *const kEncodeInstructor = @"kEncodeInstructor";
NSString *const kEncodeCredits = @"kEncodeCredits";
NSString *const kEncodeClassLink = @"kEncodeClassLink";
NSString *const kEncodeCatalogLink = @"kEncodeCatalogLink";
NSString *const kEncodeSectionNum = @"kEncodeSectionNum";
NSString *const kEncodeClassLocation = @"kEncodeClassLocation";
NSString *const kEncodeInstructorEmail = @"kEncodeInstructorEmail";
NSString *const kEncodeLinkedID = @"kEncodeLinkedID";
NSString *const kEncodeLinkedSection = @"kEncodeLinkedSection";

@implementation PCFClassModel

-(id)initWithClassTitle:(NSString *)classTitle crn:(NSString *)crn courseNumber:(NSString *)courseNumber Time:(NSString *)Time Days:(NSString *)Days DateRange:(NSString *)daterange ScheduleType:(NSString *)scheduletype Instructor:(NSString *)Instructor Credits:(NSString *)Credits ClassLink:(NSString *)ClassLink CatalogLink:(NSString *)CatalogLink SectionNum:(NSString *)SectionNum ClassLocation:(NSString *)ClassLocation Email:(NSString *)InstructorEmail linkedID:(NSString *)linkedID linkedSection:(NSString *)linkedSection
{
    self.classTitle = classTitle;
    self.CRN = crn;
    self.courseNumber = courseNumber;
    self.time = Time;
    self.days = Days;
    self.dateRange = daterange;
    self.scheduleType = scheduletype;
    self.instructor = Instructor;
    self.credits = Credits;
    self.classLink = ClassLink;
    self.catalogLink = CatalogLink;
    self.sectionNum = SectionNum;
    self.classLocation = ClassLocation;
    self.instructorEmail = InstructorEmail;
    self.linkedID = linkedID;
    self.linkedSection = linkedSection;
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init]))
    {
        self.classTitle = [aDecoder decodeObjectForKey:kEncodeClassTitle];
        self.CRN    = [aDecoder decodeObjectForKey:kEncodeCRN];
        self.courseNumber   = [aDecoder decodeObjectForKey:kEncodeCourseNumber];
        self.time = [aDecoder decodeObjectForKey:kEncodeTime];
        self.days    = [aDecoder decodeObjectForKey:kEncodeDays];
        self.dateRange   = [aDecoder decodeObjectForKey:kEncodeDateRange];
        self.scheduleType = [aDecoder decodeObjectForKey:kEncodescheduleType];
        self.instructor    = [aDecoder decodeObjectForKey:kEncodeInstructor];
        self.credits   = [aDecoder decodeObjectForKey:kEncodeCredits];
        self.classLink = [aDecoder decodeObjectForKey:kEncodeClassLink];
        self.catalogLink    = [aDecoder decodeObjectForKey:kEncodeCatalogLink];
        self.sectionNum   = [aDecoder decodeObjectForKey:kEncodeSectionNum];
        self.classLocation = [aDecoder decodeObjectForKey:kEncodeClassLocation];
        self.instructorEmail    = [aDecoder decodeObjectForKey:kEncodeInstructorEmail];
        self.linkedSection = [aDecoder decodeObjectForKey:kEncodeLinkedSection];
        self.linkedID = [aDecoder decodeObjectForKey:kEncodeLinkedID];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.classTitle forKey:kEncodeClassTitle];
    [aCoder encodeObject:self.CRN forKey:kEncodeCRN];
    [aCoder encodeObject:self.courseNumber forKey:kEncodeCourseNumber];
    [aCoder encodeObject:self.time forKey:kEncodeTime];
    [aCoder encodeObject:self.days forKey:kEncodeDays];
    [aCoder encodeObject:self.dateRange forKey:kEncodeDateRange];
    [aCoder encodeObject:self.scheduleType forKey:kEncodescheduleType];
    [aCoder encodeObject:self.instructor forKey:kEncodeInstructor];
    [aCoder encodeObject:self.credits forKey:kEncodeCredits];
    [aCoder encodeObject:self.classLink forKey:kEncodeClassLink];
    [aCoder encodeObject:self.catalogLink forKey:kEncodeCatalogLink];
    [aCoder encodeObject:self.sectionNum forKey:kEncodeSectionNum];
    [aCoder encodeObject:self.classLocation forKey:kEncodeClassLocation];
    [aCoder encodeObject:self.instructorEmail forKey:kEncodeInstructorEmail];
    [aCoder encodeObject:self.linkedID forKey:kEncodeLinkedID];
    [aCoder encodeObject:self.linkedSection forKey:kEncodeLinkedSection];
}
-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        PCFClassModel *obj2 = (PCFClassModel *)object;
        if ([self.courseNumber isEqualToString:obj2.courseNumber] && [self.classTitle isEqualToString:obj2.classTitle] && [self.CRN isEqualToString:[obj2 CRN]]) return YES;
    }
    return NO;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"Course: %@, Title: %@, CRN: %@, Time: %@, Location: %@, Professor: %@, Professor Email: %@\n", self.courseNumber, self.classTitle, self.CRN, self.time, self.classLocation, self.instructor, self.instructorEmail];
}


@end
