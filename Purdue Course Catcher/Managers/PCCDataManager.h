//
//  PCCDataManager.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFClassModel;

@interface PCCDataManager : NSObject

typedef enum
{
    DataDictionaryUser = 1,
    DataDictionarySchedule = 2,
    DataDictionarySubject = 3
} DataDictionary;

+(instancetype)sharedInstance;

-(BOOL)saveData;
-(BOOL)loadData;

-(void)setObject:(id)obj ForKey:(NSString *)key InDictionary:(DataDictionary)dictionary;
-(id)getObjectFromDictionary:(DataDictionary)dictionary WithKey:(NSString *)key;

-(void)resetData;

/*
 Dictionary for saving data
 ->  Favorites   -> array
 ->  Basket      -> array
 ->  Terms       -> array
 ->  Professors  -> array of terms -> professors by term
 ->  Schedule    -> dictionary of users -> dictionary of terms ->  schedule by term
 ->  Subject     -> array of terms -> subjects by term
 ->  User        ->  of elements like purdue username/password ..etc
                 -> preferred search semester
                 -> dictionary of PINS -> term, pin
 */
//keys in kUser dictionary
#define kPreferredSearchTerm @"kPreferredSearchTerm"
#define kPreferredRegistrationTerm @"kPreferredRegistrationTerm"
#define kPreferredScheduleToShow @"kPreferredScheduleToShow"
#define kDeviceToken @"kDeviceToken"
#define kEducationInfoDictionary @"kEducationInfoDictionary"
#define kPinDictionary @"kPinDictionary"
//within this
#define kName @"kName"
#define kClassification @"kClassification"
#define kMajor @"kMajor"
#define kAdmitTerm @"kAdmitTerm"

#define kSettings @"kSettings"
#define kNickname @"kNickname"
#define kFindByMajor @"kFindByMajor"
#define kViewMySchedule @"kViewMySchedule"

#define kCredentials @"kCredentials"
//login info
#define kUsername @"kUsername"
#define kPassword @"kPassword"
//user id
#define kUserID @"id"
//server initialization
#define kInitialized @"initialized"

#define kPurchasedItem @"kPurchasedItem"


//withint he subject dictionry
#define kSubject @"kSubject"
#define kScheduleType @"kScheduleType"
#define kCurrentUser @"kCurrentUser"

//key:value = user:dictionary
@property (nonatomic, strong) NSMutableDictionary *topLevelDictionary;

@property (nonatomic, strong) NSMutableArray *arrayBasket;
@property (nonatomic, strong) NSMutableArray *arrayNotifications;
@property (nonatomic, strong) NSMutableArray *arrayTerms;
@property (nonatomic, strong) NSMutableArray *arrayProfessors;
@property (nonatomic, strong) NSMutableArray *arrayPurchases;


@property (nonatomic, strong) NSMutableDictionary *dictionarySubjects;
@property (nonatomic, strong) NSMutableDictionary *dictionarySchedule;
@property (nonatomic, strong) NSMutableDictionary *dictionaryUser;

@property (nonatomic, strong) NSString *currentUser;

@end
