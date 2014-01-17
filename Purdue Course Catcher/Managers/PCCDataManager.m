//
//  PCCDataManager.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCDataManager.h"
#import "PCCObject.h"
#import "PCFClassModel.h"

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

-(NSMutableArray *)arrayBasket
{
    if (!_arrayBasket) _arrayBasket = [NSMutableArray arrayWithCapacity:4];
    return _arrayBasket;
}

-(void)setArrayProfessors:(NSMutableArray *)arrayProfessors
{
    if (!_arrayProfessors) {
        _arrayProfessors = arrayProfessors;
        return;
    }else if (!arrayProfessors) {
            _arrayProfessors = nil;
        return;
        }
    
    if (_arrayProfessors.count == arrayProfessors.count) return;
    //add remaining items that are not different
    for (PCCObject *object in arrayProfessors) {
        if (![_arrayProfessors containsObject:object]) [_arrayProfessors addObject:object];
    }
    
}

-(void)setArrayTerms:(NSMutableArray *)arrayTerms
{

    if (!_arrayTerms) {
        _arrayTerms = arrayTerms;
        return;
    }else if (!arrayTerms) {
        _arrayTerms = nil;
        return;
    }
    
    if (_arrayTerms.count == arrayTerms.count) return;
    //add remaining items that are not different
    for (PCCObject *object in arrayTerms) {
        if (![_arrayTerms containsObject:object]) [_arrayTerms addObject:object];
    }
}

-(BOOL)saveData
{
/*    if (self.arrayBasket || self.arrayFavorites || self.arrayProfessors || self.dictionarySchedule || self.arrayTerms || self.dictionaryUser || self.dictionarySubjects) {
 */
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *fullPath = [docDir stringByAppendingFormat:@"/%@", kFileName];
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
        if (!_arrayBasket)  {
            [dictionary setObject:[NSNull null] forKey:kBasket];
        }else {
            [dictionary setObject:_arrayBasket forKey:kBasket];
        }
        if (!_arrayFavorites) {
            [dictionary setObject:[NSNull null] forKey:kFavorites];
        }else {
            [dictionary setObject:_arrayFavorites forKey:kFavorites];
        }
        if (!_arrayProfessors) {
            [dictionary setObject:[NSNull null] forKey:kProfessors];
        }else {
            [dictionary setObject:_arrayProfessors forKey:kProfessors];
        }
        if (!_dictionarySchedule) {
            [dictionary setObject:[NSNull null] forKey:kSchedule];
        }else {
            [dictionary setObject:_dictionarySchedule forKey:kSchedule];
            
        }if (!_arrayTerms) {
            [dictionary setObject:[NSNull null] forKey:kTerms];
        }else {
            [dictionary setObject:_arrayTerms forKey:kTerms];
        }
        
        if (!_dictionaryUser) {
            [dictionary setObject:[NSNull null] forKey:kUser];
        }else {
            [dictionary setObject:_dictionaryUser forKey:kUser];
        }
        
        if (!_dictionarySubjects) {
            [dictionary setObject:[NSNull null] forKey:kSubjects];
        }else {
            [dictionary setObject:_dictionarySubjects forKey:kSubjects];
        }
    
            return [NSKeyedArchiver archiveRootObject:[dictionary copy] toFile:fullPath];
    
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

-(IBAction)resetPressed:(id)sender
{
    [self resetData];
}
-(void)resetData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [docDir stringByAppendingFormat:@"/%@", kFileName];
    NSError *error;
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
    if (!success || error) {
        
    }
    exit(0);
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
    [self saveData];
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


