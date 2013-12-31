//
//  PCCDataManager.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCDataManager.h"
#import "PCCObject.h"

@implementation PCCDataManager

static NSString *kFileName = @"data.bin";
static PCCDataManager *_sharedInstance = nil;

#define kBasket @"kBasket"
#define kFavorites @"kFavorites"
#define kProfessors @"kProfessors"
#define kSchedule @"kSchedule"
#define kTerms @"kTerms"
#define kUser @"kUser"
#define kSubjects @"kSubjects"

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[PCCDataManager alloc] init];
    });
    
    return _sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        [self loadData];
    }
    
    return self;
}

-(NSMutableDictionary *)dictionaryUser
{
    if (!_dictionaryUser) _dictionaryUser = [NSMutableDictionary dictionaryWithCapacity:4];
    return _dictionaryUser;
}

-(NSMutableDictionary *)dictionarySchedule
{
    if (!_dictionarySchedule) _dictionarySchedule = [NSMutableDictionary dictionaryWithCapacity:4];
    return _dictionarySchedule;
}

-(NSMutableDictionary *)dictionarySubjects
{
    if (!_dictionarySubjects) _dictionarySubjects = [NSMutableDictionary dictionaryWithCapacity:4];
    return _dictionarySubjects;
}

-(void)setArrayProfessors:(NSMutableArray *)arrayProfessors
{
    if (!_arrayProfessors) {
        _arrayProfessors = arrayProfessors;
        return;
    }
    
    if (_arrayProfessors.count == arrayProfessors.count) return;
    //add remaining items that are not different
    for (PCCObject *object in arrayProfessors) {
        if (![_arrayProfessors containsObject:object]) [_arrayProfessors addObject:object];
    }
    
}
-(BOOL)saveData
{
    if (self.arrayBasket || self.arrayFavorites || self.arrayProfessors || self.dictionarySchedule || self.arrayTerms || self.dictionaryUser || self.dictionarySubjects) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *fullPath = [docDir stringByAppendingFormat:@"/%@", kFileName];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
        if (!self.arrayBasket)  {
            [dictionary setObject:[NSNull null] forKey:kBasket];
        }else {
            [dictionary setObject:self.arrayBasket forKey:kBasket];
        }
        if (!self.arrayFavorites) {
            [dictionary setObject:[NSNull null] forKey:kFavorites];
        }else {
            [dictionary setObject:self.arrayFavorites forKey:kFavorites];
        }
        if (!self.arrayProfessors) {
            [dictionary setObject:[NSNull null] forKey:kProfessors];
        }else {
            [dictionary setObject:self.arrayProfessors forKey:kProfessors];
        }
        if (!self.dictionarySchedule) {
            [dictionary setObject:[NSNull null] forKey:kSchedule];
        }else {
            [dictionary setObject:self.dictionarySchedule forKey:kSchedule];
            
        }if (!self.arrayTerms) {
            [dictionary setObject:[NSNull null] forKey:kTerms];
        }else {
            [dictionary setObject:self.arrayTerms forKey:kTerms];
        }
        
        if (!self.dictionaryUser) {
            [dictionary setObject:[NSNull null] forKey:kUser];
        }else {
            [dictionary setObject:self.dictionaryUser forKey:kUser];
        }
        
        if (!self.dictionarySubjects) {
            [dictionary setObject:[NSNull null] forKey:kSubjects];
        }else {
            [dictionary setObject:self.dictionarySubjects forKey:kSubjects];
        }
    
            return [NSKeyedArchiver archiveRootObject:[dictionary copy] toFile:fullPath];
        
    }
    
    return NO;
}

-(BOOL)loadData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [docDir stringByAppendingFormat:@"/%@", kFileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
    if (fileExists) {
        NSDictionary *dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
        
        _arrayBasket = [dictionary objectForKey:kBasket];
        _arrayFavorites = [dictionary objectForKey:kFavorites];
        _arrayProfessors = [dictionary objectForKey:kProfessors];
        _dictionarySchedule = [dictionary objectForKey:kSchedule];
        _arrayTerms = [dictionary objectForKey:kTerms];
        _dictionaryUser = [dictionary objectForKey:kUser];
        _dictionarySubjects = [dictionary objectForKey:kSubjects];
        
        if ([_arrayBasket isEqual:[NSNull null]]) _arrayBasket = nil;
        if ([_arrayFavorites isEqual:[NSNull null]]) _arrayFavorites = nil;
        if ([_arrayProfessors isEqual:[NSNull null]]) _arrayProfessors = nil;
        if ([_dictionarySchedule isEqual:[NSNull null]]) _dictionarySchedule = nil;
        if ([_arrayTerms isEqual:[NSNull null]]) _arrayTerms = nil;
        if ([_dictionaryUser isEqual:[NSNull null]]) _dictionaryUser = nil;
        if ([_dictionarySubjects isEqual:[NSNull null]]) _dictionarySubjects = nil;
        return YES;
    }
    
    return NO;
}

-(void)setObject:(id)obj ForKey:(NSString *)key InDictionary:(DataDictionary)dictionary
{
    NSMutableDictionary *dict;
    
    if (dictionary == DataDictionarySchedule) {
        dict = self.dictionarySchedule;
    }else if (dictionary == DataDictionaryUser) {
        dict = self.dictionaryUser;
    }else if (dictionary == DataDictionarySubject) {
        dict = self.dictionarySubjects;
    }
    
    [dict setObject:obj forKey:key];
}

-(id)getObjectFromDictionary:(DataDictionary)dictionary WithKey:(NSString *)key
{
    NSMutableDictionary *dict;
    
    if (dictionary == DataDictionarySchedule) {
        dict = self.dictionarySchedule;
    }else if (dictionary == DataDictionaryUser) {
        dict = self.dictionaryUser;
    }else if (dictionary == DataDictionarySubject) {
        dict = self.dictionarySubjects;
    }
    
    if (!dict) return nil;
    return [dict objectForKey:key];
}



@end


