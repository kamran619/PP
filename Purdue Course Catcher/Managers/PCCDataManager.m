//
//  PCCDataManager.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCDataManager.h"

@implementation PCCDataManager

static NSString *kFileName = @"data.bin";
static PCCDataManager *_sharedInstance = nil;

#define kBasket @"kBasket"
#define kFavorites @"kFavorites"
#define kProfessors @"kProfessors"
#define kSchedule @"kSchedule"
#define kTerms @"kTerms"
#define kUser @"kUser"

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

-(BOOL)saveData
{
    if (self.arrayBasket || self.arrayFavorites || self.arrayProfessors || self.dictionarySchedule || self.arrayTerms || self.dictionaryUser) {
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
        
        self.arrayBasket = [dictionary objectForKey:kBasket];
        self.arrayFavorites = [dictionary objectForKey:kFavorites];
        self.arrayProfessors = [dictionary objectForKey:kProfessors];
        self.dictionarySchedule = [dictionary objectForKey:kSchedule];
        self.arrayTerms = [dictionary objectForKey:kTerms];
        self.dictionaryUser = [dictionary objectForKey:kUser];
        
        if ([self.arrayBasket isEqual:[NSNull null]]) self.arrayBasket = nil;
        if ([self.arrayFavorites isEqual:[NSNull null]]) self.arrayFavorites = nil;
        if ([self.arrayProfessors isEqual:[NSNull null]]) self.arrayProfessors = nil;
        if ([self.dictionarySchedule isEqual:[NSNull null]]) self.dictionarySchedule = nil;
        if ([self.arrayTerms isEqual:[NSNull null]]) self.arrayTerms = nil;
        if ([self.dictionaryUser isEqual:[NSNull null]]) self.dictionaryUser = nil;
        
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
    }
    
    if (!dict) return nil;
    return [dict objectForKey:key];
}



@end


