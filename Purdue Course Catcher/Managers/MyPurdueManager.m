//
//  MyPurdueManager.m
//  PurdueLogin
//
//  Created by Kamran Pirwani on 10/10/13.
//  Copyright (c) 2013 kpirwani. All rights reserved.
//

#import "MyPurdueManager.h"
#import "PCCObject.h"
#import "PCFClassModel.h"
#import "PCCCourseSlots.h"
#import "Course.h"
#import "PCFNetworkManager.h"
#import "PCCDataManager.h"
#import "Helpers.h"
#import "PCCRegistrationError.h"

enum Parse
{
    ParseSemester                                       = 0,
    ParseSubjectAndProfessors                           = 1,
    ParseClasses                                        = 2,
    ParseSlots                                          = 3,
    ParseCourseCatalog                                  = 4,
    ParseCRN                                            = 5,
    ParseCourseReviews                                  = 6,
    ParseScheduleDataFromWeekAtAGlance                  = 7,
    ParseScheduleDataFromConciseSchedule                = 8,
    ParseScheduleDataFromDetailSchedule                 = 9,
    ParseStudentInformation                             = 10,
    ParseRegistration                                   = 11,
    ParseRegistrationError                              = 12,
    ParsePin                                            = 13,
    ParseTermCount                                      = 14 //for viewing pin//custom
};

#define URL_SEMESTER @"https://selfservice.mypurdue.purdue.edu/prod/bwckschd.p_disp_dyn_sched?"
#define URL_COURSE_SEARCH @"https://selfservice.mypurdue.purdue.edu/prod/bwckschd.p_get_crse_unsec"
#define URL_LINK_FROM_TERM @"https://selfservice.mypurdue.purdue.edu/prod/bwckgens.p_proc_term_date"

#define URL_BANNER_DISPLAYLOGIN @"https://wl.mypurdue.purdue.edu/cp/home/displaylogin"
#define URL_BANNER_LOGINF @"https://wl.mypurdue.purdue.edu/cp/home/loginf"
#define URL_BANNER_LOGIN @"https://wl.mypurdue.purdue.edu/cp/home/login"
#define URL_BANNER_ORIGIN @"https://wl.mypurdue.purdue.edu"

#define URL_CONNECTION_SETTINGS_CONNECTION @"keep-alive"
#define URL_CONNECTION_SETTINGS_ACCEPT @"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
#define URL_CONNECTION_SETTINGS_CONTENT_TYPE @"application/x-www-form-urlencoded"
#define URL_CONNECTION_SETTINGS_USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_4) AppleWebKit/536.30.1 (KHTML, like Gecko) Version/6.0.5 Safari/536.30.1"

@interface MyPurdueManager()
+(NSString *)queryServer:(NSString *)address connectionType:(NSString *)type referer:(NSString *)referer arguements:(NSString *)args;
+(id)parseData:(NSString *)data type:(int)type term:(NSString *)term;
+(NSArray *)getCoursesWithQueryString:(NSString *)queryString;
-(void)setupRequest:(NSMutableURLRequest *)request type:(NSString *)type host:(NSString *)host origin:(NSString *)origin referer:(NSString *)referer;
@end

@implementation MyPurdueManager
{
    //time it takes to contact server for intial request(needed by Purdue)
    long long int clientServerDelta;
}

static MyPurdueManager *_sharedInstance = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MyPurdueManager alloc] init];
    });
    return _sharedInstance;
}

-(id)init
{
    if (self = [super init]) {
    }
    return self;
}

-(void)loginWithSuccessBlock:(void(^)())success andFailure:(void(^)())failure
{
    [Helpers asyncronousBlockWithName:@"Check registration" AndBlock:^{
        NSDictionary *credentials = [Helpers getCredentials];
        NSString *username, *password;
        username = [credentials objectForKey:kUsername];
        password = [credentials objectForKey:kPassword];
        
        if ([self loginWithUsername:username andPassword:password] == NO) {
            NSLog(@"The login failed");
            if (failure) failure();
        }else {
            if (success) success();
        }
    }];
}

-(BOOL)loginWithUsername:(NSString *)user andPassword:(NSString *)pass
{
    NSString *data;
    NSMutableURLRequest *request;
    data = [[self class] queryServer:URL_BANNER_DISPLAYLOGIN connectionType:@"GET" referer:URL_BANNER_LOGINF arguements:nil];
    clientServerDelta = -1;
    //received response
    long long value = [self findValueFromData:data];
    clientServerDelta = [[NSDate date] timeIntervalSince1970];
    clientServerDelta -= value;
    //push login now
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URL_BANNER_LOGIN] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:URL_BANNER_ORIGIN referer:URL_BANNER_LOGIN];
    long long uuid = [[NSDate date] timeIntervalSince1970] - clientServerDelta;
    NSData *requestBody = [[NSString stringWithFormat:@"pass=%@&user=%@&uuid=%lld", pass, user, uuid] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    data = [[self class] queryServerWithRequest:request];
    //login respo/Users/kamranpirwani/Desktop/Git/PCC/Purdue Course Catcher.xcodeprojnse received
    //validate it
    NSRange range = [data rangeOfString:@"loginok.html" options:NSCaseInsensitiveSearch];
    
    //lets get their information if we have never gotten it
    if (range.location != NSNotFound) {
        [Helpers setCurrentUser:user];
        if (![[PCCDataManager sharedInstance].dictionaryUser objectForKey:kEducationInfoDictionary]) {
            [Helpers asyncronousBlockWithName:@"Get Student Info" AndBlock:^{
                NSDictionary *studentDictionary = [[MyPurdueManager sharedInstance] getStudentInformation];
                [[PCCDataManager sharedInstance] setObject:studentDictionary ForKey:kEducationInfoDictionary InDictionary:DataDictionaryUser];
                if (![Helpers getInitialization]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReceivedFTUEComplete object:nil];
                }
                //no longer need to send here, sent at the end of the FTUE
                //[[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandUpdate withDictionary:studentDictionary];
            }];
            
        }
    }
    return !(range.location == NSNotFound);
}

-(NSArray *)getCurrentScheduleViaWeekAtAGlance
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //return [self gotoUPNP];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:@"https://wl.mypurdue.purdue.edu" referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    data = [[self class] queryServerWithRequest:request];
    /*
    //goto Academic
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/tag.255ba722eec6462f.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"];
    data = [[self class] queryServerWithRequest:request];
    //return [self gotoWeekAtAGlance];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_WEEKGLANCE"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/tag.255ba722eec6462f.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="];
    data = [[self class] queryServerWithRequest:request];
    //return [self gotoWeekAtAGlanceTwo];
     */
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm=backLinked&uP_tparam=utf&utf=&/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_WEEKGLANCE"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_WEEKGLANCE"];
    data = [[self class] queryServerWithRequest:request];
    //return [self gotoLoginTwo];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_WEEKGLANCE"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_WEEKGLANCE"];
    data = [[self class] queryServerWithRequest:request];
    //return [self getSchedule];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfshd.P_CrseSchd"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_WEEKGLANCE"];
    data = [[self class] queryServerWithRequest:request];
    NSRange range = [data rangeOfString:@"<TITLE>Consent To Conduct Business Electronically</TITLE>" options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) {
        return [[self class] parseData:data type:ParseScheduleDataFromWeekAtAGlance term:nil];
    }else {
        NSLog(@"Logon and accept purdue agreement");
        return nil;
    }
}

-(NSDictionary *)getStudentInformation
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //return [self gotoUPNP];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:@"https://wl.mypurdue.purdue.edu" referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    data = [[self class] queryServerWithRequest:request];
    //goto Academic
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/tag.255ba722eec6462f.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"];
    data = [[self class] queryServerWithRequest:request];
    //parse here
    return [[self class] parseData:data type:ParseStudentInformation term:nil];
}

- (NSArray *)getCurrentScheduleViaDetailSchedule {
    PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow];
    return [self getCurrentScheduleViaDetailScheduleWithTerm:term];
}

-(NSArray *)getCurrentScheduleViaDetailScheduleWithTerm:(PCCObject *)term
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //return [self gotoUPNP];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:@"https://wl.mypurdue.purdue.edu" referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    data = [[self class] queryServerWithRequest:request];
    /*goto Academic
     request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/tag.255ba722eec6462f.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
     [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"];
     data = [[self class] queryServerWithRequest:request];
     */
    //goto concise schedule
    /*request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
     [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/tag.f8d77798926caba4.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="];
     data = [[self class] queryServerWithRequest:request];
     */
    //2
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm=backLinked&uP_tparam=utf&utf=&/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //3
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //4
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskcrse.P_CrseSchdDetl"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_DETSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //final post
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfshd.P_CrseSchdDetl"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"selfservice.mypurdue.purdue.edu" origin:@"https://selfservice.mypurdue.purdue.edu" referer:@"https://selfservice.mypurdue.purdue.edu/prod/bwskcrse.P_CrseSchdDetl"];
    PCCObject *obj = term;
    NSString *form_parameter = [NSString stringWithFormat:@"term_in=%@", obj.value];
    NSData *requestBody = [form_parameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    data = [[self class] queryServerWithRequest:request];
    //schedule data parsed differently unfortunately :(
    return [[self class] parseData:data type:ParseScheduleDataFromDetailSchedule term:nil];
}

-(NSArray *)getCurrentScheduleViaConciseSchedule
{
    return [self getCurrentScheduleViaConciseScheduleWithTerm:[[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow]];
}


-(NSArray *)getCurrentScheduleViaConciseScheduleWithTerm:(PCCObject *)term
{
    /*NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
     [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
     NSString *data = [[self class] queryServerWithRequest:request];
     //return [self gotoUPNP];
     request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
     [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:@"https://wl.mypurdue.purdue.edu" referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
     data = [[self class] queryServerWithRequest:request];
     */
    /*
     //goto Academic
     request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/tag.255ba722eec6462f.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
     [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"];
     data = [[self class] queryServerWithRequest:request];
     //goto concise schedule
     request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
     [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/tag.f8d77798926caba4.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="];
     data = [[self class] queryServerWithRequest:request];
     */
    //2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm=backLinked&uP_tparam=utf&utf=&/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //3
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //4
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskcrse.P_CrseSchdDetl"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_CONCSCHED"];
    data = [[self class] queryServerWithRequest:request];
    //final post
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskcrse.P_CrseSchdDetl"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"selfservice.mypurdue.purdue.edu" origin:@"https://selfservice.mypurdue.purdue.edu" referer:@"https://selfservice.mypurdue.purdue.edu/prod/bwskcrse.P_CrseSchdDetl"];
    PCCObject *obj = term;
    NSString *form_parameter = [NSString stringWithFormat:@"term_in=%@", obj.value];
    NSData *requestBody = [form_parameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    data = [[self class] queryServerWithRequest:request];
    //schedule data parsed differently unfortunately :(
    return [[self class] parseData:data type:ParseScheduleDataFromConciseSchedule term:nil];
    return nil;
}


-(NSString *)getPinForSemester:(NSString *)semester
{
    NSMutableURLRequest *request;
    NSString *data;
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    data = [[self class] queryServerWithRequest:request];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:@"https://wl.mypurdue.purdue.edu" referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    data = [[self class] queryServerWithRequest:request];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"]];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/tag.d8a9d147e09000d.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="];
    data = [[self class] queryServerWithRequest:request];
    //insert
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm=backLinked&uP_tparam=utf&utf=&/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"]];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"];
    data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"]];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"];
    data = [[self class] queryServerWithRequest:request];
    //
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"]];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"];
    data = [[self class] queryServerWithRequest:request];
    //show terms
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/szwvpin.p_selectaltpinterm"]];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_REGPIN"];
    data = [[self class] queryServerWithRequest:request];
    NSString *term_count = [[self class] parseData:data type:ParseTermCount term:nil];
    //post
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/szwvpin.p_dispaltpin"]];
    [self setupRequest:request type:@"POST" host:@"selfservice.mypurdue.purdue.edu" origin:@"https://selfservice.mypurdue.purdue.edu" referer:@"https://selfservice.mypurdue.purdue.edu/prod/szwvpin.p_selectaltpinterm"];
    NSString *form_parameter = [NSString stringWithFormat:@"termcount_in=%@&term_in=%@", term_count, semester];
    NSData *requestBody = [form_parameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    data = [[self class] queryServerWithRequest:request];
    return [[self class] parseData:data type:ParsePin term:nil];
}

-(NSArray *)getRegistrationTerms
{
    /*NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //return [self gotoUPNP];
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:@"https://wl.mypurdue.purdue.edu" referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    data = [[self class] queryServerWithRequest:request];
    //
    */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/tag.10ddb9d4797b3327.render.userLayoutRootNode.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm="]];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.userLayoutRootNode.uP?uP_root=root"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"]];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm=backLinked&uP_tparam=utf&utf=&/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"]];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"]];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    data = [[self class] queryServerWithRequest:request];
    //registration term
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_AltPin"]];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    //parse this to get info
    data = [[self class] queryServerWithRequest:request];
    NSArray *terms = [[self class] parseData:data type:ParseSemester term:nil];
    return terms;
}

-(NSDictionary *)canRegisterForTerm:(NSString *)term withPin:(NSString *)pin
{
    /*NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/home/next"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/cps/welcome/loginok.html"];
    NSString *data = [[self class] queryServerWithRequest:request];
     */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    NSString *data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://wl.mypurdue.purdue.edu/render.uP?uP_root=root&uP_sparam=activeTab&activeTab=u12l1s2&uP_tparam=frm&frm=backLinked&uP_tparam=utf&utf=&/cp/ip/login?sys=sctssb&url=https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"wl.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    data = [[self class] queryServerWithRequest:request];
    /*
    //registration term
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_AltPin"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    //parse this to get info
    data = [[self class] queryServerWithRequest:request];
     */
    //
    /*request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    data = [[self class] queryServerWithRequest:request];*/
    //
    /*
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/gokcsso.p_call_banner_sserv?sess_token=S1BJULDBTKK=DZBKZJINIXQOZNTBOGXS&url=https%3A%2F%2Fselfservice.mypurdue.purdue.edu%2Fprod%2Ftzwkwbis.P_CheckAgreeAndRedir%3Fret_code%3DSTU_ADDDROP"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:nil host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://wl.mypurdue.purdue.edu/render.UserLayoutRootNode.uP?uP_tparam=utf&utf=%2fcp%2fip%2flogin%3fsys%3dsctssb%26url%3dhttps://selfservice.mypurdue.purdue.edu/prod/tzwkwbis.P_CheckAgreeAndRedir?ret_code=STU_ADDDROP"];
    data = [[self class] queryServerWithRequest:request];*/
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_AltPin"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_AltPin"];
    //post which semester here
    NSString *form_parameter = [NSString stringWithFormat:@"term_in=%@", term];
    NSData *requestBody = [form_parameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    data = [[self class] queryServerWithRequest:request];
    //
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_CheckAltPin"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"selfservice.mypurdue.purdue.edu" origin:nil referer:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_AltPin"];
    //alt pin post
    //NSMutableDictionary *pinDictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
    //NSString *pin = [pinDictionary objectForKey:term];
    //NSString *pin = @"270283";
    form_parameter = [NSString stringWithFormat:@"pin=%@", pin];
    requestBody = [form_parameter dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //if Add or Drop Class success
    data = [[self class] queryServerWithRequest:request];
    NSRange success = [data rangeOfString:@"Add or Drop Classes" options:NSCaseInsensitiveSearch];
    NSRange auth = [data rangeOfString:@"Authorization Failure" options:NSCaseInsensitiveSearch];
    
    NSMutableArray *array = [MyPurdueManager parseData:data type:ParseRegistration term:nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"response", @"data", nil];
    NSArray *values;
    NSNumber *response;
    NSString *error;

    if (success.location != NSNotFound) {
        NSString *kLookForError = @"<SPAN class=\"errortext\">";
        NSRange found = [data rangeOfString:kLookForError options:NSCaseInsensitiveSearch];
        if (found.location != NSNotFound) {
            response = [NSNumber numberWithInt:PCCErrorUnkownError];
            int from = found.location + found.length;
            NSScanner *lilScanner = [NSScanner scannerWithString:data];
            [lilScanner setScanLocation:from];
            [lilScanner scanUpToString:@"</SPAN>" intoString:&error];
            keys = [NSArray arrayWithObjects:@"response", @"data", @"error", nil];
            values = [NSArray arrayWithObjects:response, array, error, nil];
            return [NSDictionary dictionaryWithObjects:values forKeys:keys];
        }else {
            response = [NSNumber numberWithInt:PCCErrorOk];
        }
        
    }else if (auth.location != NSNotFound) {
        response = [NSNumber numberWithInt:PCCErrorInvalidPin];
    }else {
        response = [NSNumber numberWithInt:PCCErrorUnkownError];
    }
    
    values = [NSArray arrayWithObjects:response, array, nil];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

-(NSDictionary *)submitRegistrationChanges:(NSString *)query
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://selfservice.mypurdue.purdue.edu/prod/bwckcoms.P_Regs"] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:10.0f];
    [self setupRequest:request type:@"POST" host:@"selfservice.mypurdue.purdue.edu" origin:@"https://selfservice.mypurdue.purdue.edu" referer:@"https://selfservice.mypurdue.purdue.edu/prod/bwskfreg.P_CheckAltPin"];
    NSData *requestBody = [query dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[requestBody length]];
    [request setHTTPBody:requestBody];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    NSString *result = [[self class] queryServerWithRequest:request];
    NSArray *registeredClasses = [[self class] parseData:result type:ParseRegistration term:nil];
    
    NSArray *keys, *values;
    NSNumber *response;
    NSString *title = @"";
    NSArray *errorObjects;
    
    NSRange error;
    error = [result rangeOfString:@"errortext"];
    if (error.location == NSNotFound) {
        response = [NSNumber numberWithInt:PCCErrorOk];
        keys = [NSArray arrayWithObjects:@"response", @"data", nil];
        values = [NSArray arrayWithObjects:response, registeredClasses, nil];
    }else {
        response = [NSNumber numberWithInt:PCCErrorUnkownError];
        NSDictionary *dictionary = [[self class] parseData:result type:ParseRegistrationError term:nil];
        title = [dictionary objectForKey:@"title"];
        errorObjects = [dictionary objectForKey:@"errors"];
        keys = [NSArray arrayWithObjects:@"response", @"data", @"title", @"errors",  nil];
        values = [NSArray arrayWithObjects:response, registeredClasses, title, errorObjects, nil];
    }
    
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
}
-(void)setupRequest:(NSMutableURLRequest *)request type:(NSString *)type host:(NSString *)host origin:(NSString *)origin referer:(NSString *)referer{
    
    if (type) [request setHTTPMethod:type];
    if (host) [request setValue:host forHTTPHeaderField:@"Host"];
    if (origin) [request setValue:origin forHTTPHeaderField:@"Origin"];
    if (referer) [request setValue:referer forHTTPHeaderField:@"Referer"];
    
    //setup additional requests
    [request setValue:URL_CONNECTION_SETTINGS_CONNECTION forHTTPHeaderField:@"Connection"];
    [request setValue:URL_CONNECTION_SETTINGS_ACCEPT
   forHTTPHeaderField:@"Accept"];
    [request setValue:URL_CONNECTION_SETTINGS_CONTENT_TYPE forHTTPHeaderField:@"Content-Type"];
    [request setValue:URL_CONNECTION_SETTINGS_USER_AGENT   forHTTPHeaderField:@"User-Agent"];
}

- (long long)findValueFromData:(NSString *)str
{
    @try {
        NSScanner *scanner = [[NSScanner alloc] initWithString:str];
        [scanner scanUpToString:@"var clientServerDelta = (new Date()).getTime() -" intoString:nil];
        [scanner setScanLocation:scanner.scanLocation + 49];
        NSString *value = nil;
        [scanner scanUpToString:@";" intoString:&value];
        return  [value longLongValue];
    }
    @catch (NSException *exception) {
        return -1;
    }
}



#pragma mark Class Methods

//retrieve the semesters for Purdue
+(NSArray *)getTerms
{
        NSArray *term = nil;
        NSString *webData = [[self class] queryServer:URL_SEMESTER connectionType:nil referer:nil arguements:nil];
        if (webData) term = [[self class] parseData:webData type:ParseSemester term:nil];
    return term;
}

//retrieve the semesters for Purdue without clutter and only the most 5 recent ones
+(NSArray *)getMinimalTerms
{
    NSMutableArray *legitimateElements = [NSMutableArray arrayWithCapacity:3];
    NSArray *term = [[self class] getTerms];
    for (PCCObject *obj in term) {
        NSString *val = obj.value;
        if (![[val substringFromIndex:[val length] - 2] isEqualToString:@"15"]) [legitimateElements addObject:obj];
    }
    
    if (legitimateElements.count > 0) term = [legitimateElements subarrayWithRange:NSMakeRange(0, 4)];
    return [term copy];
}

//General Search
+(NSArray *)getCoursesWithParametersForTerm:(NSString *)term WithClassName:(NSString *)className AndCourseNumber:(NSString *)courseNumber AndSubject:(NSString *)subject FromHours:(NSString *)fromHours ToHours:(NSString *)toHours AndProfessor:(NSString *)professor AndDays:(NSString *)days scheduleType:(NSString *)scheduleType
{

    NSString *queryString = [NSString stringWithFormat:@"term_in=%@&sel_subj=dummy&sel_day=dummy&sel_schd=dummy&sel_insm=dummy&sel_camp=dummy&sel_levl=dummy&sel_sess=dummy&sel_instr=dummy&sel_ptrm=dummy&sel_attr=dummy&sel_subj=%@&sel_crse=%@&sel_title=%@&sel_schd=%@&sel_from_cred=%@&sel_to_cred=%@&sel_camp=%%25&sel_ptrm=%%25&sel_instr=%@&sel_sess=%%25&sel_attr=%%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a%@", term, subject, courseNumber,className, scheduleType, fromHours, toHours,professor, days];
    return [self getCoursesWithQueryString:queryString];

}

//Equivalent to Quick Search
+(NSArray *)getCoursesForTerm:(NSString *)term WithClassName:(NSString *)className AndCourseNumber:(NSString *)courseNumber
{
    
    NSString *queryString = [NSString stringWithFormat:@"term_in=%@&sel_subj=dummy&sel_day=dummy&sel_schd=dummy&sel_insm=dummy&sel_camp=dummy&sel_levl=dummy&sel_sess=dummy&sel_instr=dummy&sel_ptrm=dummy&sel_attr=dummy&sel_subj=%@&sel_crse=%@&sel_title=&sel_schd=%%25&sel_from_cred=&sel_to_cred=&sel_camp=%%25&sel_ptrm=%%25&sel_instr=&sel_sess=%%25&sel_attr=%%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a", term, className, courseNumber];
    
    return [self getCoursesWithQueryString:queryString];
}

+(NSArray *)getCoursesWithQueryString:(NSString *)queryString
{
    NSArray *courses = nil;
    NSString *webData = [[self class] queryServer:URL_COURSE_SEARCH connectionType:@"POST" referer:URL_LINK_FROM_TERM arguements:queryString];
    PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    if (webData) courses = [[self class] parseData:webData type:ParseClasses term:term.value];
    return courses;
}

//Equivalent to CRN Search
+(NSArray *)getCoursesForTerm:(NSString *)term WithCRN:(NSString *)CRN
{
    NSString *URL = [NSString stringWithFormat:@"https://selfservice.mypurdue.purdue.edu/prod/bwckschd.p_disp_detail_sched?term_in=%@&crn_in=%@", term, CRN];
    NSString *queryString = [[self class] queryServer:URL connectionType:nil referer:nil arguements:nil];
    NSString *query = (NSString *)[[self class] parseData:queryString type:ParseCRN term:term];
    NSString *webData = [[self class] queryServer:URL_COURSE_SEARCH connectionType:@"POST" referer:URL_LINK_FROM_TERM arguements:query];
    NSArray *classes = [[self class] parseData:webData type:ParseClasses term:term];
    for (PCFClassModel *class in classes) {
        if ([CRN isEqualToString:class.CRN]) return [NSArray arrayWithObject:class];
    }
    return nil;
}

 //The elements in these arrays are of type PCFObject
+(NSArray *)getSubjectsAndProfessorsForTerm:(NSString *)term
{
    NSArray *genArray = nil;
    NSString *args = @"p_calling_proc=bwckschd.p_disp_dyn_sched&p_term=";
    args = [args stringByAppendingFormat:@"%@", term];
    NSString *webData = [[self class] queryServer:URL_LINK_FROM_TERM connectionType:@"POST" referer:URL_COURSE_SEARCH arguements:args];
    if (webData) {
        genArray = [[self class] parseData:webData type:ParseSubjectAndProfessors term:term];
    }
    return genArray;
}

//The elements in these arrays are of type PCFObject
+(NSArray *)getSubjectsForTerm:(NSString *)term
{
    
    return [[[self class] getSubjectsAndProfessorsForTerm:term] objectAtIndex:0];
}

//The elements in these arrays are of type PCFObject
+(NSArray *)getProfessorsForTerm:(NSString *)term
{
    return [[[self class] getSubjectsAndProfessorsForTerm:term] objectAtIndex:1];
}

+(NSString *)getCatalogInformationWithLink:(NSString *)catalogLink
{
    NSString *results = nil;
    NSString *webData = [[self class] queryServer:catalogLink connectionType:nil referer:URL_COURSE_SEARCH arguements:nil];
    if (webData) {
        results = (NSString *)[[self class] parseData:webData type:ParseCourseCatalog term:nil];
    }
    
    NSRange range = [results rangeOfString:@"CTL:" options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        results = [results substringToIndex:[results rangeOfString:@"CTL"].location];
    }
    return results;
}

+(PCCCourseSlots *)getCourseAvailabilityWithLink:(NSString *)courseLink
{
    NSString *webData = nil;
    webData = [[self class] queryServer:courseLink connectionType:nil referer:URL_COURSE_SEARCH arguements:nil];
    NSArray *courseRecord = [[self class] parseData:webData type:ParseSlots term:nil];
    PCCCourseSlots *record = [courseRecord objectAtIndex:0];
    return record;
}


#pragma mark Private Methods

//sends an URLRequest on a same thread
+(NSString *)queryServer:(NSString *)address connectionType:(NSString *)type referer:(NSString *)referer arguements:(NSString *)args
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:address] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:7];
    if (type) [request setHTTPMethod:type];
    if (referer) [request setValue:referer forHTTPHeaderField:@"Referer"];
    if (args) {
        NSData *requestBody = [args dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestBody];
    }
    return [[self class] queryServerWithRequest:request];
}

+(NSString *)queryServerWithRequest:(NSMutableURLRequest *)request
{
    NSError *error = nil;
    NSData *webData = nil;
    int counter = 0;
    while (!webData) {
        if (counter == 5) return nil;
        webData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if ([error code] == -1001) {
            NSLog(@"Retrying\n");
        }else if ([error code] == -1009) {
            [PCFNetworkManager sharedInstance].internetActive = NO;
            return @"No internet connection";
        }else if (error){
            NSLog(@"%@\n", [error description]);
            return nil;
        }
        counter++;
    }
    return [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
}

+(id)parseData:(NSString *)data type:(int)type term:(NSString *)term
{
    
    if (!data) return nil;
    
    if (type == ParseSemester) {
        static NSString *const kLookFor = @"<OPTION VALUE=";
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSScanner *tempScanner;
        NSMutableString *termVal = [NSMutableString string];
        NSMutableString *termDes = [NSMutableString string];
        NSMutableArray *semester = [NSMutableArray arrayWithCapacity:3];
        @try {
            while (![scanner isAtEnd]) {
                [scanner scanUpToString:kLookFor intoString:nil];
                //encountered <OPTION VALUE="
                [scanner setScanLocation:([scanner scanLocation] + 15)];
                [scanner scanUpToString:@"\"" intoString:&termVal];
                if ([termVal isEqual:@""]) continue;
                //NSLog(@"Term value is %@\n", termVal);
                [scanner setScanLocation:([scanner scanLocation] + 2)];
                [scanner scanUpToString:@"<" intoString:&termDes];
                tempScanner = [NSScanner scannerWithString:termDes];
                [tempScanner scanUpToString:@"(" intoString:&termDes];
                //NSLog(@"Term des is %@\n", termDes);
                [semester addObject:[[PCCObject alloc] initWithKey:termDes AndValue:termVal]];
            }
            
        }
        @catch (NSException *exception) {
            //NSLog(@"Error: %@\n", [exception description]);
        }
        @finally {
            //NSLog(@"%@", [termDict descriptionInStringsFileFormat]);
            scanner = nil;
            tempScanner = nil;
            termVal = nil;
            termDes = nil;
            return [semester copy];
        }
    }else if (type == ParseSubjectAndProfessors) {
        static NSString *const kLookFor = @"<OPTION VALUE=";
        static NSString *const kInitialHeader = @"<SELECT NAME=\"sel_subj\" SIZE=\"10\" MULTIPLE ID=\"subj_id\">";
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSMutableString *classVal = [NSMutableString string];
        NSMutableString *classDes = [NSMutableString string];
        NSMutableArray *subjectArray = [NSMutableArray arrayWithCapacity:20];
        PCCObject *subject;
        [scanner scanUpToString:kInitialHeader intoString:nil];
        while (![scanner isAtEnd]) {
            [scanner scanUpToString:kLookFor intoString:nil];
            //encountered <OPTION VALUE="
            [scanner setScanLocation:([scanner scanLocation] + 15)];
            //scan to end of "
            [scanner scanUpToString:@"\"" intoString:&classVal];
            if ([classVal isEqual:@""]) continue;
            //NSLog(@"Term value is %@\n", termVal);
            [scanner setScanLocation:([scanner scanLocation] + 2)];
            [scanner scanUpToString:@"-" intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 1)];
            [scanner scanUpToString:@"<" intoString:&classDes];
            //NSLog(@"Term des is %@\n", termDes);
            subject = [[PCCObject alloc] initWithKey:classDes AndValue:classVal];
            [subjectArray addObject:subject];
            if ([@"YDAE" isEqualToString:classVal]) break;
            if ([@"STAR" isEqualToString:classVal]) break;
        }
        static NSString *const kLookForScheduleType = @"<SELECT NAME=\"sel_schd\" SIZE=\"3\" MULTIPLE ID=\"schd_id\">";
        [scanner scanString:kLookForScheduleType intoString:nil];
        [scanner setScanLocation:([scanner scanLocation] + 55)];
        NSString *scheduleType, *scheduleTypeVal;
        NSMutableArray *scheduleTypeArray = [NSMutableArray arrayWithCapacity:7];
        BOOL passedThroughAllOnce = NO;
            while (![scanner isAtEnd]) {
                [scanner scanUpToString:@"<OPTION VALUE=\"" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 15)];
                [scanner scanUpToString:@"\"" intoString:&scheduleTypeVal];
                if ([scheduleTypeVal isEqualToString:@"%"]) {
                    if (passedThroughAllOnce == YES) {
                        break;
                    }else {
                        passedThroughAllOnce = YES;
                    }
                }
                /*
                 <OPTION VALUE="%" SELECTED>All
                 <OPTION VALUE="CLN">Clinic
                 <OPTION VALUE="DIS">Distance Learning
                 */
                //[scanner setScanLocation:([scanner scanLocation] + 2)];
                [scanner scanUpToString:@">" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 1)];
                [scanner scanUpToString:@"\n" intoString:&scheduleType];
                [scanner setScanLocation:([scanner scanLocation] + 1)];
                //scheduleType = [scheduleType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                [scheduleTypeArray addObject:[[PCCObject alloc] initWithKey:scheduleType AndValue:scheduleTypeVal]];
            }
        
        static NSString *const kLookForProf = @"<SELECT NAME=\"sel_instr\" SIZE=\"3\" MULTIPLE ID=\"instr_id\">";
        scanner = [[NSScanner alloc] initWithString:data];
        NSString *professor;
        NSString *val;
        NSMutableArray *prof = [[NSMutableArray alloc] initWithCapacity:40];
        @try {
            [scanner scanUpToString:kLookForProf intoString:nil];
            [scanner scanUpToString:@"<OPTION VALUE=\"%\" SELECTED>All" intoString:nil];
            //[scanner setScanLocation:([scanner scanLocation] + 30)];
            while (![scanner isAtEnd]) {
                [scanner scanUpToString:@"<OPTION VALUE=\"" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 15)];
                [scanner scanUpToString:@"\"" intoString:&val];
                if ([val isEqualToString:@"%"]) continue;
                [scanner setScanLocation:([scanner scanLocation] + 2)];
                [scanner scanUpToString:@"<" intoString:&professor];
                professor = [professor stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                if ([professor isEqualToString:@"Day"]) break;
                PCCObject *obj = [[PCCObject alloc] initWithKey:professor AndValue:val];
                [prof addObject:obj];
            }
        }
        @catch (NSException *) {
            
        }
        @finally {
            NSArray *combinedArray = [[NSArray alloc] initWithObjects:[subjectArray copy], [prof copy], [scheduleTypeArray copy], nil];
            scanner = nil;
            professor = nil;
            classDes = nil;
            classVal = nil;
            return combinedArray;
        }
    }else if(type == ParseClasses) {
        static NSString *const kLookFor = @"<TH CLASS=\"ddlabel\" scope=\"row\" ><A HREF=\"";
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSMutableArray *classes = [[NSMutableArray alloc] initWithCapacity:30];
        NSString *tempString, *classLink, *catalogLink, *tempCatalogLink, *classTitle, *CRN, *courseName, *sectionNum, *numCredits, *classType, *classTime, *classDays, *classLocation, *classDateRange, *scheduleType, *instructor, *instructorEmail, *linkID, *linkedSection;
        NSScanner *tempScanner;
        @try {
            while (![scanner isAtEnd]) {
                tempString = nil, classLink = nil, catalogLink = nil, tempCatalogLink = nil, classTitle = nil, CRN = nil, courseName = nil,sectionNum = nil, numCredits = nil, classType = nil, classTime = nil, classDays = nil, classLocation = nil, classDateRange = nil, scheduleType = nil, instructor = nil, instructorEmail = nil, linkID = nil, linkedSection = nil;;
                NSScanner *tempScanner;
                //encountered TH CLASS=\"ddlabel\" scope=\"row\" ><A HREF=\" - Link to Class
                [scanner scanUpToString:kLookFor intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 42)];
                [scanner scanUpToString:@"\"" intoString:&classLink];
                classLink = [@"https://selfservice.mypurdue.purdue.edu" stringByAppendingString:classLink];
                //got link now move up two spaces
                classLink = [classLink stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
                [scanner setScanLocation:([scanner scanLocation] + 2)];
                [scanner scanUpToString:@"<" intoString:&tempString];
                //use temp string for scanner
                tempString = [tempString stringByReplacingOccurrencesOfString:@"- Distance Learning" withString:@""];
                NSArray *split = [tempString componentsSeparatedByString:@" -"];
                if ([split count] == 4) {
                    tempScanner = [NSScanner scannerWithString:tempString];
                    [tempScanner scanUpToString:@" -" intoString:&classTitle];
                    [tempScanner setScanLocation:([tempScanner scanLocation] + 3)];
                    [tempScanner scanUpToString:@"-" intoString:&CRN];
                    CRN = [CRN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [tempScanner setScanLocation:([tempScanner scanLocation] + 2)];
                    [tempScanner scanUpToString:@"-" intoString:&courseName];
                    courseName = [courseName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    courseName = [courseName substringToIndex:([courseName length] - 2)];
                    [tempScanner setScanLocation:([tempScanner scanLocation] + 2)];
                    [tempScanner scanUpToString:@"<" intoString:&sectionNum];
                }else {
                    for (int i = 0; i < split.count; i++) {
                        NSString *cpy = [[split objectAtIndex:i] copy];
                        cpy = [cpy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        if ([cpy rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
                            //only numbers are here
                            //CRN is found..everything before this is the title
                            CRN = cpy;
                            courseName = [split objectAtIndex:i + 1];
                            courseName = [courseName substringFromIndex:1];
                            sectionNum = [split objectAtIndex:i + 2];
                            sectionNum = [sectionNum stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            for (int j = 0; j < i; j++) {
                                classTitle = [classTitle stringByAppendingString:[split objectAtIndex:j]];
                            }
                            break;
                        }
                    }
                }
                NSScanner *linkedScanner = [NSScanner scannerWithString:data];
                [linkedScanner setScanLocation:[scanner scanLocation]];
                [linkedScanner scanUpToString:@"Link Id:" intoString:nil];
                if ([linkedScanner scanLocation] - [scanner scanLocation] < 35) {
                    [linkedScanner setScanLocation:[linkedScanner scanLocation] + 9];
                    [linkedScanner scanUpToString:@"&" intoString:&linkID];
                    [linkedScanner scanUpToString:@"</I>(" intoString:nil];
                    [linkedScanner setScanLocation:[linkedScanner scanLocation] + 5];
                    [linkedScanner scanUpToString:@")" intoString:&linkedSection];
                    //NSLog(@"CRN : %@, Course: %@, LinkID: %@, LinkedSection: %@\n", CRN, courseName, linkID, linkedSection);
                }else {
                    linkedSection = @"";
                    linkID = @"";
                    //NSLog(@"No linked section for CRN: %@, Course: %@\n", CRN, courseName);
                }

                //done with substring extraction
                //back to scaning
                [scanner scanUpToString:@"Type" intoString:nil];
                [scanner scanUpToString:@">" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 1)];
                [scanner scanUpToString:@"<" intoString:&numCredits];
                NSString *tempStr = numCredits;
                numCredits = [tempStr substringToIndex:4];
                //numCredits = [numCredits stringByAppendingString:@" "];
                //numCredits = [numCredits stringByAppendingString:[tempStr substringFromIndex:6]];
                //get catalog link
                [scanner scanUpToString:@"<A HREF=\"" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 9)];
                [scanner scanUpToString:@"\"" intoString:&tempCatalogLink];
                catalogLink = [@"https://selfservice.mypurdue.purdue.edu" stringByAppendingString:tempCatalogLink];
                catalogLink = [catalogLink stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"<" intoString:&classType];
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"<" intoString:&classTime];
                if ([classTime isEqualToString:@""] || !classTime) classTime = @"TBA";
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"<" intoString:&classDays];
                if ([classDays isEqualToString:@"&nbsp;"]) classDays = @"TBA";
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"<" intoString:&classLocation];
                if ([classLocation isEqualToString:@""] || !classLocation) classLocation = @"TBA";
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"<" intoString:&classDateRange];
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"<" intoString:&scheduleType];
                [scanner scanUpToString:@"<TD CLASS=\"ddd" intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 22)];
                [scanner scanUpToString:@"</TD>" intoString:&instructor];
                if ([instructor rangeOfString:@"TBA" options:NSCaseInsensitiveSearch range:NSMakeRange(0, instructor.length-1)].location != NSNotFound) {
                    instructor = @"TBA";
                    instructorEmail = @"";
                }else {
                    //we have a valid instructor
                    NSScanner *tempScanner = [NSScanner scannerWithString:instructor];
                    [tempScanner scanUpToString:@"mailto:" intoString:nil];
                    [tempScanner setScanLocation:tempScanner.scanLocation + 7];
                    [tempScanner scanUpToString:@"\"" intoString:&instructorEmail];
                    [tempScanner scanUpToString:@"target=\"" intoString:nil];
                    [tempScanner setScanLocation:tempScanner.scanLocation + 8];
                    [tempScanner scanUpToString:@"\"" intoString:&instructor];
                }
                [classes addObject:[[PCFClassModel alloc] initWithClassTitle:classTitle crn:CRN
                                                                courseNumber:courseName Time:classTime Days:classDays DateRange:classDateRange ScheduleType:scheduleType Instructor:instructor Credits:numCredits ClassLink:classLink CatalogLink:catalogLink SectionNum:sectionNum ClassLocation:classLocation Email:instructorEmail linkedID:linkID linkedSection:linkedSection term:term]];
            }
            
        }
        @catch (NSException *exception) {
            //NSLog(@"Error: %@\n", [exception description]);
        }
        @finally {
            //NSLog(@"%@", [termDict descriptionInStringsFileFormat]);
            scanner = nil;
            tempScanner = nil;
            tempString = nil;
            classLink = nil;
            catalogLink = nil;
            tempCatalogLink = nil;
            classTitle = nil;
            CRN = nil;
            courseName = nil;
            sectionNum = nil;
            numCredits = nil;
            classType = nil;
            classTime = nil;
            classDays = nil;
            classLocation = nil;
            classDateRange = nil;
            scheduleType = nil;
            instructor = nil;
            instructorEmail = nil;
            return [classes copy];
        }
        
    }else if (type == ParseSlots) {
        static NSString *const kLookFor = @"<TH CLASS=\"ddlabel\" scope=\"row\" ><SPAN class=\"fieldlabeltext\">Seats</SPAN></TH>";
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSString *courseCapacity, *courseAvailability, *courseActual;
        @try {
            [scanner scanUpToString:kLookFor intoString:nil];
            [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 22)];
            [scanner scanUpToString:@"<" intoString:&courseCapacity];
            [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 22)];
            [scanner scanUpToString:@"<" intoString:&courseActual];
            
            [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 22)];
            [scanner scanUpToString:@"<" intoString:&courseAvailability];
            PCCCourseSlots *rec = [[PCCCourseSlots alloc] initWithCapacity:courseCapacity enrolled:courseAvailability remaining:courseActual];
            NSArray *arr = [NSArray arrayWithObject:rec];
            return arr;
        }
        @catch (NSException *exception) {
            //NSLog(@"Error: %@\n", [exception description]);
        }
        @finally {
            //NSLog(@"%@", [termDict descriptionInStringsFileFormat]);
            scanner = nil;
            courseActual = nil;
            courseAvailability = nil;
            courseCapacity = nil;
        }
        
    }else if(type == ParseCourseCatalog) {
        static NSString *const kLookFor = @"<TD CLASS=\"ntdefault\">";
        NSString *desc;
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSString *courseCatalogDescription;
        @try {
            [scanner scanUpToString:kLookFor intoString:nil];
            [scanner scanUpToString:@"." intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 1)];
            [scanner scanUpToString:@"." intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 1)];
            [scanner scanUpToString:@"<" intoString:&courseCatalogDescription];
            desc = courseCatalogDescription;
        }
        @catch (NSException *exception) {
            //NSLog(@"Error: %@\n", [exception description]);
        }
        @finally {
            scanner = nil;
            return (NSArray *)desc;
        }
        
    }else if(type == ParseCRN) {
        static NSString *const kLookFor = @"<TH CLASS=\"ddlabel\" scope=\"row\" >";
        NSScanner *scanner = [[NSScanner alloc] initWithString:data];
        @try {
            
            [scanner scanUpToString:kLookFor intoString:nil];
            [scanner setScanLocation:([scanner scanLocation] + 33)];
            NSString *tempString, *courseName, *courseCRN, *coursePrefix, *courseSuffix;
            [scanner scanUpToString:@"<" intoString:&tempString];
            NSScanner *tempScanner = [[NSScanner alloc] initWithString:tempString];
            [tempScanner scanUpToString:@"-" intoString:&courseName];
            [tempScanner setScanLocation:([tempScanner scanLocation] + 1)];
            courseName = [courseName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [tempScanner scanUpToString:@"-" intoString:&courseCRN];
            [tempScanner setScanLocation:([tempScanner scanLocation] + 2)];
            courseCRN = [courseCRN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [tempScanner scanUpToString:@" " intoString:&coursePrefix];
            [tempScanner setScanLocation:([tempScanner scanLocation] + 1)];
            [tempScanner scanUpToString:@"-" intoString:&courseSuffix];
            courseSuffix = [courseSuffix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            courseSuffix = [courseSuffix substringToIndex:([courseSuffix length]-2)];
            NSString *queryString;
            if ([courseName length] > 25) {
                queryString = [NSString stringWithFormat:@"term_in=%@&sel_subj=dummy&sel_day=dummy&sel_schd=dummy&sel_insm=dummy&sel_camp=dummy&sel_levl=dummy&sel_sess=dummy&sel_instr=dummy&sel_ptrm=dummy&sel_attr=dummy&sel_subj=%@&sel_crse=%@&sel_title=&sel_schd=%%25&sel_from_cred=&sel_to_cred=&sel_camp=%%25&sel_ptrm=%%25&sel_instr=&sel_sess=%%25&sel_attr=%%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a", term, coursePrefix, courseSuffix];
            }else {
                courseName = [courseName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                queryString = [NSString stringWithFormat:@"term_in=%@&sel_subj=dummy&sel_day=dummy&sel_schd=dummy&sel_insm=dummy&sel_camp=dummy&sel_levl=dummy&sel_sess=dummy&sel_instr=dummy&sel_ptrm=dummy&sel_attr=dummy&sel_subj=%@&sel_crse=%@&sel_title=%@&sel_schd=%%25&sel_from_cred=&sel_to_cred=&sel_camp=%%25&sel_ptrm=%%25&sel_instr=&sel_sess=%%25&sel_attr=%%25&begin_hh=0&begin_mi=0&begin_ap=a&end_hh=0&end_mi=0&end_ap=a", term, coursePrefix, courseSuffix, courseName];
            }
            
            return (NSArray *)queryString;
            
        }@catch(NSException *) {
            
        }@finally {
            scanner = nil;
        }
        return nil;
    }else if (type==ParseCourseReviews) {
        //class review
        static NSString *const kLookFor = @"<TH CLASS=\"ddlabel\" scope=\"row\" ><A HREF=\"";
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSMutableArray *classes = [[NSMutableArray alloc] initWithCapacity:3];
        NSString *tempString, *classLink, *catalogLink, *tempCatalogLink, *classTitle, *CRN, *courseName, *sectionNum, *numCredits, *classType, *classTime, *classDays, *classLocation, *classDateRange, *scheduleType, *instructor, *instructorEmail;
        NSScanner *tempScanner;
        @try {
            while (![scanner isAtEnd]) {
                tempString = nil, classLink = nil, catalogLink = nil, tempCatalogLink = nil, classTitle = nil, CRN = nil, courseName = nil,sectionNum = nil, numCredits = nil, classType = nil, classTime = nil, classDays = nil, classLocation = nil, classDateRange = nil, scheduleType = nil, instructor = nil, instructorEmail = nil;
                NSScanner *tempScanner;
                //encountered TH CLASS=\"ddlabel\" scope=\"row\" ><A HREF=\" - Link to Class
                [scanner scanUpToString:kLookFor intoString:nil];
                [scanner setScanLocation:([scanner scanLocation] + 42)];
                [scanner scanUpToString:@"\"" intoString:&classLink];
                classLink = [@"https://selfservice.mypurdue.purdue.edu" stringByAppendingString:classLink];
                //got link now move up two spaces
                classLink = [classLink stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
                [scanner setScanLocation:([scanner scanLocation] + 2)];
                [scanner scanUpToString:@"<" intoString:&tempString];
                //use temp string for scanner
                tempScanner = [NSScanner scannerWithString:tempString];
                [tempScanner scanUpToString:@" -" intoString:&classTitle];
                [tempScanner setScanLocation:([tempScanner scanLocation] + 3)];
                [tempScanner scanUpToString:@"-" intoString:&CRN];
                CRN = [CRN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [tempScanner setScanLocation:([tempScanner scanLocation] + 2)];
                [tempScanner scanUpToString:@"-" intoString:&courseName];
                courseName = [courseName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                courseName = [courseName substringToIndex:([courseName length] - 2)];
                PCCObject *class = [[PCCObject alloc] initWithKey:courseName AndValue:classTitle];
                BOOL dupe = NO;
                for (PCCObject *course in classes) {
                    if ([course.value isEqualToString:classTitle]) {
                        dupe = YES;
                        break;
                    }
                }
                if (!dupe) [classes addObject:class];
            }
            
        }
        @catch (NSException *exception) {
            //NSLog(@"Error: %@\n", [exception description]);
        }
        @finally {
            //NSLog(@"%@", [termDict descriptionInStringsFileFormat]);
            scanner = nil;
            tempScanner = nil;
            tempString = nil;
            classLink = nil;
            catalogLink = nil;
            tempCatalogLink = nil;
            classTitle = nil;
            CRN = nil;
            courseName = nil;
            return [classes copy];
        }
    }else if(type == ParseScheduleDataFromWeekAtAGlance) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
        @try {
            while (![scanner isAtEnd]) {
                NSString *token = nil, *crn, *course, *time, *location, *link;
                [scanner scanUpToString:@"CLASS=\"ddlabel\"><A HREF=\"" intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 25];
                [scanner scanUpToString:@"\">" intoString:&link];
                link = [NSString stringWithFormat:@"https://selfservice.mypurdue.purdue.edu%@", link];
                [scanner setScanLocation:scanner.scanLocation + 2];
                [scanner scanUpToString:@"</A>" intoString:&token];
                if (!token) break;
                NSArray *tempCourse = [token componentsSeparatedByString:@"<BR>"];
                course = [tempCourse objectAtIndex:0];
                crn = [tempCourse objectAtIndex:1];
                NSArray *crnSplit = [crn componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                time = [tempCourse objectAtIndex:2];
                location = [tempCourse objectAtIndex:3];
                Course *scheduledCourse = [[Course alloc] initWithCourse:course crn:[crnSplit objectAtIndex:0] time:time location:location link:link];
                if (![array containsObject:scheduledCourse]) [array addObject:scheduledCourse];
            }
        }@catch (NSException *exception) {
            //NSLog(@"%@", exception.description);
        }
        @finally {
            scanner = nil;
            return array;
        }
    }else if (type == ParseScheduleDataFromConciseSchedule) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
        @try {
            while (![scanner isAtEnd]) {
                NSString *token = nil, *crn, *course, *time, *location, *link;
                [scanner scanUpToString:@"CLASS=\"ddlabel\"><A HREF=\"" intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 25];
                [scanner scanUpToString:@"\">" intoString:&link];
                link = [NSString stringWithFormat:@"https://selfservice.mypurdue.purdue.edu%@", link];
                [scanner setScanLocation:scanner.scanLocation + 2];
                [scanner scanUpToString:@"</A>" intoString:&token];
                if (!token) break;
                NSArray *tempCourse = [token componentsSeparatedByString:@"<BR>"];
                course = [tempCourse objectAtIndex:0];
                crn = [tempCourse objectAtIndex:1];
                NSArray *crnSplit = [crn componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                time = [tempCourse objectAtIndex:2];
                location = [tempCourse objectAtIndex:3];
                Course *scheduledCourse = [[Course alloc] initWithCourse:course crn:[crnSplit objectAtIndex:0] time:time location:location link:link];
                if (![array containsObject:scheduledCourse]) [array addObject:scheduledCourse];
            }
        }@catch (NSException *exception) {
            //NSLog(@"%@", exception.description);
        }
        @finally {
            scanner = nil;
            return array;
        }
    }else if (type == ParseScheduleDataFromDetailSchedule) {
            NSScanner *scanner = [NSScanner scannerWithString:data];
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:4];
            @try {
                while (![scanner isAtEnd]) {
                    NSString *crn, *course, *courseName, *courseTitle, *section, *time, *days, *dateRange, *instructor, *instructorEmail, *location, *credits, *classType;
                    [scanner scanUpToString:@"<TABLE  CLASS=\"datadisplaytable\" SUMMARY=\"This layout table is used to present the schedule course detail\"><CAPTION class=\"captiontext\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 136];
                    [scanner scanUpToString:@"<" intoString:&course];
                    NSArray *splitCourse = [course componentsSeparatedByString:@"-"];
                    if ([splitCourse count] == 3) {
                        courseTitle = [splitCourse objectAtIndex:0];
                        courseTitle = [courseTitle substringToIndex:courseTitle.length - 1];
                        courseName = [splitCourse objectAtIndex:1];
                        courseName = [courseName substringToIndex:courseName.length - 3];
                        courseName = [courseName substringFromIndex:1];
                        section = [splitCourse objectAtIndex:2];
                    }else {
                        [NSException raise:@"Course name incorrectly formatted" format:@"Please check to see if the course was parsed properly"];
                    }
                    [scanner scanUpToString:@"CRN" intoString:nil];
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"<" intoString:&crn];
                    [scanner scanUpToString:@"<TH COLSPAN=\"2\" CLASS=\"ddlabel\" scope=\"row\" >Credits:</TH>" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 58];
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">    " intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 26];
                    [scanner scanUpToString:@"<" intoString:&credits];
                    credits = [credits substringToIndex:[credits length] - 1];
                    [scanner scanUpToString:@"<TABLE  CLASS=\"datadisplaytable\" SUMMARY=\"This table lists the scheduled meeting times and assigned instructors for this class..\"><CAPTION class=\"captiontext\">Scheduled Meeting Times</CAPTION>" intoString:nil];
                    //class type
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:nil];
                    //time
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:&time];
                    if ([time rangeOfString:@"TBA" options:NSCaseInsensitiveSearch range:NSMakeRange(0, time.length-1)].location != NSNotFound) time = @"TBA";
                    //days
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:&days];
                    if ([days isEqualToString:@"&nbsp;"]) days = @"N/A";
                    //where
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:&location];
                    if ([location rangeOfString:@"TBA" options:NSCaseInsensitiveSearch range:NSMakeRange(0, location.length-1)].location != NSNotFound) location = @"TBA";
                    //date range
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:&dateRange];
                    if ([dateRange rangeOfString:@"TBA" options:NSCaseInsensitiveSearch range:NSMakeRange(0, dateRange.length-1)].location != NSNotFound) dateRange = @"TBA";
                    //schedule type
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:&classType];
                    //instructors
                    [scanner scanUpToString:@"<TD CLASS=\"dddefault\">" intoString:nil];
                    [scanner setScanLocation:scanner.scanLocation + 22];
                    [scanner scanUpToString:@"</TD>" intoString:&instructor];
                    if ([instructor rangeOfString:@"TBA" options:NSCaseInsensitiveSearch range:NSMakeRange(0, instructor.length-1)].location != NSNotFound) {
                        instructor = @"TBA";
                        instructorEmail = @"N/A";
                    }else {
                        //we have a valid instructor
                        NSScanner *tempScanner = [NSScanner scannerWithString:instructor];
                        [tempScanner scanUpToString:@"mailto:" intoString:nil];
                        [tempScanner setScanLocation:tempScanner.scanLocation + 7];
                        [tempScanner scanUpToString:@"\"" intoString:&instructorEmail];
                        [tempScanner scanUpToString:@"target=\"" intoString:nil];
                        [tempScanner setScanLocation:tempScanner.scanLocation + 8];
                        [tempScanner scanUpToString:@"\"" intoString:&instructor];
                    }
                    PCFClassModel *scheduledCourse = [[PCFClassModel alloc] initWithClassTitle:courseTitle crn:crn courseNumber:courseName Time:time Days:days DateRange:dateRange ScheduleType:classType Instructor:instructor Credits:credits ClassLink:nil CatalogLink:nil SectionNum:section ClassLocation:location Email:instructorEmail linkedID:nil linkedSection:nil term:term];
                    if (![array containsObject:scheduledCourse]) [array addObject:scheduledCourse];
                }
            }@catch (NSException *exception) {
                //NSLog(@"%@", exception.description);
            }
            @finally {
                scanner = nil;
                return array;
            }
    }else if (type == ParseStudentInformation) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        [scanner setCaseSensitive:YES];
        NSString *name, *classification, *major;
        
        NSString *kLookForName = @"Welcome";
        
        //get name by searching for Welcome message
        [scanner scanUpToString:kLookForName intoString:nil];
        [scanner setScanLocation:scanner.scanLocation + 8];
        [scanner scanUpToString:@"<" intoString:&name];
        
        NSString *kLookForClassStanding = @"Class Standing";
        
        [scanner scanUpToString:kLookForClassStanding intoString:nil];
        [scanner scanUpToString:@"class=\"uportal-text\">" intoString:nil];
        [scanner setScanLocation:scanner.scanLocation + 21];
        [scanner scanUpToString:@"<" intoString:&classification];
        //remove hours
        NSArray *arr = [classification componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        classification = [arr objectAtIndex:0];
        
        NSString *kLookForMajor = @"Major:";
        [scanner scanUpToString:kLookForMajor intoString:nil];
        [scanner scanUpToString:@"class=\"uportal-text\">" intoString:nil];
        [scanner setScanLocation:scanner.scanLocation + 21];
        [scanner scanUpToString:@"<" intoString:&major];
        
        //remove & from major
        major = [major stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        NSArray *objects = [NSArray arrayWithObjects:name, classification, major, nil];
        NSArray *keys = [NSArray arrayWithObjects:kName, kClassification, kMajor, nil];
        return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    }else if (type == ParseRegistration) {
        NSString *kLookForStatus = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"MESG\"";
        NSString *kLookForTerm = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"assoc_term_in\" VALUE=\"";
        NSString *kLookForCRN = @"NAME=\"CRN_IN\" VALUE=\"";
        NSString *kLookForStartDate = @"NAME=\"start_date_in\" VALUE=\"";
        NSString *kLookForEndDate = @"NAME=\"end_date_in\" VALUE=\"";
        NSString *kLookForSubject = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"SUBJ\" VALUE=\"";
        NSString *kLookForCourse = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"CRSE\" VALUE=\"";
        NSString *kLookForSection = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"SEC\" VALUE=\"";
        NSString *kLookForLevel = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"LEVL\" VALUE=\"";
        NSString *kLookForGradeMode = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"GMOD\" VALUE=\"";
        NSString *kLookForCredits = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"CRED\" VALUE=\"    ";
        NSString *kLookForTitle = @"<TD CLASS=\"dddefault\"><INPUT TYPE=\"hidden\" NAME=\"TITLE\" VALUE=\"";
        NSString *subject, *course, *credits, *title, *status, *term, *crn, *startDate, *endDate, *section, *level, *gradeMode;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];
        
        NSScanner *scanner = [NSScanner scannerWithString:data];
        
        @try {
            while (![scanner isAtEnd]) {
                [scanner scanUpToString:kLookForStatus intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 53];
                [scanner scanUpToString:@">" intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 1];
                [scanner scanUpToString:@"<" intoString:&status];
                
                [scanner scanUpToString:kLookForTerm intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 71];
                [scanner scanUpToString:@"\"" intoString:&term];
                
                [scanner scanUpToString:kLookForCRN intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 21];
                [scanner scanUpToString:@"\"" intoString:&crn];
                
                [scanner scanUpToString:kLookForStartDate intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 28];
                [scanner scanUpToString:@"\"" intoString:&startDate];
                
                [scanner scanUpToString:kLookForEndDate intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 26];
                [scanner scanUpToString:@"\"" intoString:&endDate];
                
                [scanner scanUpToString:kLookForSubject intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 62];
                [scanner scanUpToString:@"\"" intoString:&subject];
                
                [scanner scanUpToString:kLookForCourse intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 62];
                [scanner scanUpToString:@"\"" intoString:&course];
                
                [scanner scanUpToString:kLookForSection intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 61];
                [scanner scanUpToString:@"\"" intoString:&section];
                
                [scanner scanUpToString:kLookForLevel intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 62];
                [scanner scanUpToString:@"\"" intoString:&level];
                
                [scanner scanUpToString:kLookForCredits intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 66];
                [scanner scanUpToString:@"\"" intoString:&credits];

                [scanner scanUpToString:kLookForGradeMode intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 62];
                [scanner scanUpToString:@"\"" intoString:&gradeMode];
                
                [scanner scanUpToString:kLookForTitle intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 63];
                [scanner scanUpToString:@"\"" intoString:&title];
                
                course = [course substringToIndex:course.length-2];
                NSString *courseNumber = [NSString stringWithFormat:@"%@ %@", subject, course];
                PCFClassModel *class = [[PCFClassModel alloc] initWithClassTitle:title crn:crn courseNumber:courseNumber Time:nil Days:nil DateRange:nil ScheduleType:nil Instructor:nil Credits:credits ClassLink:nil CatalogLink:nil SectionNum:section ClassLocation:nil Email:nil linkedID:nil linkedSection:nil term:term];
                class.gradeMode = gradeMode;
                class.level = level;
                class.startDate = startDate;
                class.endDate = endDate;
                class.status = status;
            
                [array addObject:class];
            }
        }@catch (NSException *e) {
            //NSLog(@"%@", e.description);
        }@finally {
            return array;
        }
    }else if (type == ParseRegistrationError) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSString *kLookForError = @"errortext";
        NSString *kLookForNextField = @"<TD CLASS=\"dddefault\">";
        NSString *title, *subject, *courseNumber, *message, *crn, *course;
        NSMutableArray *regErrors = [NSMutableArray arrayWithCapacity:2];
        @try {
            
            [scanner scanUpToString:kLookForError intoString:nil];
            [scanner setScanLocation:scanner.scanLocation + 24];
            [scanner scanUpToString:@"<" intoString:&title];
            
            while (![scanner isAtEnd]) {
                [scanner scanUpToString:kLookForNextField intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 22];
                [scanner scanUpToString:@"<" intoString:&message];

                //crn
                [scanner scanUpToString:kLookForNextField intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 22];
                [scanner scanUpToString:@"<" intoString:&crn];
                
                //subject
                [scanner scanUpToString:kLookForNextField intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 22];
                [scanner scanUpToString:@"<" intoString:&subject];
                
                //course number
                [scanner scanUpToString:kLookForNextField intoString:nil];
                [scanner setScanLocation:scanner.scanLocation + 22];
                [scanner scanUpToString:@"<" intoString:&courseNumber];
                
                course = [NSString stringWithFormat:@"%@ %@", subject, [courseNumber substringToIndex:courseNumber.length-2]];
                
                [scanner scanUpToString:@"<TR>" intoString:nil];
                PCCRegistrationError *regError = [[PCCRegistrationError alloc] initWithErrorMessage:message crn:crn course:course];
                [regErrors addObject:regError];
            }
        }@catch (NSException *exception) {
            //NSLog(@"%@", exception.description);
        }@finally {
            return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, regErrors.copy, nil] forKeys:[NSArray arrayWithObjects:@"title", @"errors", nil]];
        }
    }else if (type == ParsePin) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSString *kLookForPin = @"<TD CLASS=\"dddefault\"><p class=\"centeraligntext\"";
        NSString *pin;
        @try {
            
            [scanner scanUpToString:kLookForPin intoString:nil];
            [scanner setScanLocation:scanner.scanLocation + 49];
            [scanner scanUpToString:kLookForPin intoString:nil];
            [scanner setScanLocation:scanner.scanLocation + 49];
            [scanner scanUpToString:@"<" intoString:&pin];
            
        }@catch (NSException *exception) {
            //NSLog(@"%@", exception.description);
        }@finally {
            return pin;
        }
    }else if (type == ParseTermCount) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        NSString *kLookForCount = @"<INPUT TYPE=\"hidden\" NAME=\"termcount_in\" VALUE=\"";
        NSString *strPin;
        @try {
            [scanner scanUpToString:kLookForCount intoString:nil];
            [scanner setScanLocation:scanner.scanLocation + 48];
            [scanner scanUpToString:@"\"" intoString:&strPin];
        }@catch (NSException *exception) {
            //NSLog(@"%@", exception);
        }@finally {
            return strPin;
        }
    }
}

-(NSString *)generateQueryString:(NSArray *)currentCourses andRegisteringCourses:(NSArray *)registeringCourses andDroppingCourses:(NSArray *)droppingCourses;
{
    PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    NSString *query = [NSString stringWithFormat:@"term_in=%@&RSTS_IN=DUMMY&assoc_term_in=DUMMY&CRN_IN=DUMMY&start_date_in=DUMMY&end_date_in=DUMMY&SUBJ=DUMMY&CRSE=DUMMY&SEC=DUMMY&LEVL=DUMMY&CRED=DUMMY&GMOD=DUMMY&TITLE=DUMMY&MESG=DUMMY&REG_BTN=DUMMY&MESG=DUMMY", term.value];
    for (int i = 0; i < currentCourses.count; i++) {
        PCFClassModel *class = [currentCourses objectAtIndex:i];
        NSArray *splitDate = [class.startDate componentsSeparatedByString:@"/"];
        NSString *startDate = [NSString stringWithFormat:@"%@%%2F%@%%2F%@", splitDate[0], splitDate[1], splitDate[2]];
        splitDate = [class.endDate componentsSeparatedByString:@"/"];
        NSString *endDate = [NSString stringWithFormat:@"%@%%2F%@%%2F%@", splitDate[0], splitDate[1], splitDate[2]];
        NSString *drop = ([droppingCourses containsObject:class] == YES) ? @"DW" : @"";
        NSArray *courseSplit = [class.courseNumber componentsSeparatedByString:@" "];
        NSString *subject = courseSplit[0];
        NSString *course = [NSString stringWithFormat:@"%@00", courseSplit[1]];
        NSString *gradeMode = [class.gradeMode stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *title = [class.classTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *innerQuery = [NSString stringWithFormat:@"&RSTS_IN=%@&assoc_term_in=%@&CRN_IN=%@&start_date_in=%@&end_date_in=%@&SUBJ=%@&CRSE=%@&SEC=%@&LEVL=%@&CRED=++++%@&GMOD=%@&TITLE=%@&MESG=DUMMY", drop, class.term ,class.CRN, startDate, endDate, subject, course, class.sectionNum, class.level, class.credits, gradeMode, title];
        query = [query stringByAppendingString:innerQuery];
    }
    
    for (PCFClassModel *class in registeringCourses) {
        NSString *innerQuery = [NSString stringWithFormat:@"&RSTS_IN=RW&CRN_IN=%@&assoc_term_in=&start_date_in=&end_date_in=", class.CRN];
        query = [query stringByAppendingString:innerQuery];
    }
    
    int count = 10 - (int)registeringCourses.count;
    for (; count > 0; count--) {
        query = [query stringByAppendingString:@"&RSTS_IN=RW&CRN_IN=&assoc_term_in=&start_date_in=&end_date_in="];
    }
    
    query = [query stringByAppendingString:[NSString stringWithFormat:@"&regs_row=%lu&wait_row=0&add_row=10&REG_BTN=Submit+Changes", (unsigned long)currentCourses.count]];
    return query;
}

@end
