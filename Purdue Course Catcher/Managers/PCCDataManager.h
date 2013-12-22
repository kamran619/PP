//
//  PCCDataManager.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCCDataManager : NSObject

typedef enum
{
    DataDictionaryUser = 1,
    DataDictionarySchedule = 2
} DataDictionary;

+(instancetype)sharedInstance;

-(BOOL)saveData;
-(BOOL)loadData;

-(void)setObject:(id)obj ForKey:(NSString *)key InDictionary:(DataDictionary)dictionary;
-(id)getObjectFromDictionary:(DataDictionary)dictionary WithKey:(NSString *)key;

/*
 Dictionary for saving data
 ->  Favorites   -> array
 ->  Basket      -> array
 ->  Terms       -> array
 ->  Professors  -> array of terms -> professors by term
 ->  Schedule    -> array of terms ->  schedule by term
 ->  User        -> nsdictionary of elements like purdue username/password ..etc
                ->preferred search semester
 */
//keys in kUser dictionary
#define kPreferredSearchTerm @"kPreferredSearchTerm"
#define kPreferredScheduleToShow @"kPreferredScheduleToShow"

@property (nonatomic, strong) NSMutableArray *arrayFavorites;
@property (nonatomic, strong) NSMutableArray *arrayBasket;
@property (nonatomic, strong) NSMutableArray *arrayTerms;
@property (nonatomic, strong) NSMutableArray *arrayProfessors;
@property (nonatomic, strong) NSMutableDictionary *dictionarySchedule;
@property (nonatomic, strong) NSMutableDictionary *dictionaryUser;

@end
