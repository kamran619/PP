//
//  PCFClassModel.m
//  Purdue Course Finder
//
//  Created by Kamran Pirwani on 10/29/12.
//  Copyright (c) 2012 Kamran Pirwani. All rights reserved.
//

#import "PCFClassModel.h"

static NSString *const kEncodeClassTitle = @"kEncodeClassTitle";
static NSString *const kEncodeCRN = @"kEncodeCRN";
static NSString *const kEncodeCourseNumber = @"kEncodeCourseNumber";
static NSString *const kEncodeTime = @"kEncodeTime";
static NSString *const kEncodeDays = @"kEncodeDays";
static NSString *const kEncodeDateRange = @"kEncodeDateRange";
static NSString *const kEncodeClassType = @"kEncodeClassType";
static NSString *const kEncodescheduleType = @"kEncodeScheduleType";
static NSString *const kEncodeInstructor = @"kEncodeInstructor";
static NSString *const kEncodeCredits = @"kEncodeCredits";
static NSString *const kEncodeClassLink = @"kEncodeClassLink";
static NSString *const kEncodeCatalogLink = @"kEncodeCatalogLink";
static NSString *const kEncodeSectionNum = @"kEncodeSectionNum";
static NSString *const kEncodeClassLocation = @"kEncodeClassLocation";
static NSString *const kEncodeInstructorEmail = @"kEncodeInstructorEmail";
static NSString *const kEncodeLinkedID = @"kEncodeLinkedID";
static NSString *const kEncodeLinkedSection = @"kEncodeLinkedSection";
static NSString *const kEncodeTerm = @"kEncodeTerm";
@implementation PCFClassModel

-(id)initWithClassTitle:(NSString *)classTitle crn:(NSString *)crn courseNumber:(NSString *)courseNumber Time:(NSString *)Time Days:(NSString *)Days DateRange:(NSString *)daterange ScheduleType:(NSString *)scheduletype Instructor:(NSString *)Instructor Credits:(NSString *)Credits ClassLink:(NSString *)ClassLink CatalogLink:(NSString *)CatalogLink SectionNum:(NSString *)SectionNum ClassLocation:(NSString *)ClassLocation Email:(NSString *)InstructorEmail linkedID:(NSString *)linkedID linkedSection:(NSString *)linkedSection term:(NSString *)term
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
    self.term = term;
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
        self.term = [aDecoder decodeObjectForKey:kEncodeTerm];
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
    [aCoder encodeObject:self.term forKey:kEncodeTerm];
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
