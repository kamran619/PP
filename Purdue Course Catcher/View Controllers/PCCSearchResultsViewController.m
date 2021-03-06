//
//  PCCSearchResultsViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchResultsViewController.h"
#import "PCCSearchResultsCell.h"
#import "PCFClassModel.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCCourseSlots.h"
#import <MessageUI/MessageUI.h>
#import "KPLightBoxManager.h"
#import "PCCHUDManager.h"
#import "PCCCatalogViewController.h"
#import "DropAnimationController.h"
#import "ZoomAnimationController.h"
#import "PCFNetworkManager.h"
#import "PCCDataManager.h"
#import "PCCRegistrationBasketViewController.h"
#import "PCCLinkedSectionViewController.h"
#import "PCCSearchResultsFilterViewController.h"
#import "PCCObject.h"
#import "UIView+Animations.h"
#import "PCCPurdueLoginViewController.h"
#import "PCCRegistrationStatusViewViewController.h"

@interface PCCSearchResultsViewController ()
{
    PCCCatalogViewController *catalogVC;
    PCCSearchResultsFilterViewController *filterVC;
    NSArray *linkedCourses;
    //allow registration or notifications
    BOOL allowAction;
    BOOL retreievedValidTerms;
    NSArray *coursesToRegister;
    
}
@end

@implementation PCCSearchResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationController = [[DropAnimationController alloc] init];
    [self getLinkedCoursesWithBlock:nil];
    [self initController];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)initController
{
    allowAction = NO;
    retreievedValidTerms = NO;
    //detect if we should register or allow notifications to classes for this term
    PCCObject *currentSearchTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
        [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
            NSArray *terms = [[MyPurdueManager sharedInstance] getRegistrationTerms];
            retreievedValidTerms = YES;
            if ([terms containsObject:currentSearchTerm]) {
                allowAction = YES;
            }
            [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }andFailure:^{
            retreievedValidTerms = YES;
            allowAction = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The Purdue login credentials you have provided are invalid or have changed. Please update these to continue fully using this app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Update" , nil];
                alertView.tag = 1;
                [alertView show];
            });
        }];
}

-(void)reloadData
{
    [self.tableView reloadData];
}
-(void)getLinkedCoursesWithBlock:(void(^)())block
{
    if (self.searchType == searchCRN) {
        [Helpers asyncronousBlockWithName:@"Get linked courses" AndBlock:^{
            PCFClassModel *class = (self.dataSource.count > 0) ? [self.dataSource objectAtIndex:0] : nil;
            if ([class.linkedID isEqualToString:@""]) return;
            NSString *course = class.courseNumber;
            NSArray *split = [course componentsSeparatedByString:@" "];
            PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
            linkedCourses = [MyPurdueManager getCoursesForTerm:term.value WithClassName:[split objectAtIndex:0] AndCourseNumber:[split objectAtIndex:1]];
            if (block) block();
        }];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"kSearchResultsCell";
    PCCSearchResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    PCFClassModel *obj;
    
    if (self.isFiltered) {
        obj = [self.filteredDataSource objectAtIndex:indexPath.row];
    }else {
        obj = [self.dataSource objectAtIndex:indexPath.row];
    }
    
    cell.course = obj;
    
    NSArray *timeArray = [Helpers splitTime:obj.time];
    if (timeArray) {
        [[cell startTime] setText:[timeArray objectAtIndex:0]];
        [[cell endTime] setText:[timeArray objectAtIndex:1]];
    }
    
    [[cell location] setText:obj.classLocation];
    [[cell courseName] setText:obj.courseNumber];
    [[cell courseTitle] setText:obj.classTitle];
    [[cell courseType] setText:obj.scheduleType];
    [[cell date] setText:obj.dateRange];
    [[cell courseSection] setText:obj.sectionNum];
    [[cell days] setText:obj.days];
    int credits = [obj.credits intValue];
    NSString *credit;
    if (credits !=1) {
        credit = @"credits";
    }else {
        credit = @"credit";
    }
    [[cell credits] setText:[NSString stringWithFormat:@"%d %@", credits, credit]];
    [[cell crn] setText:obj.CRN];
    [[cell professor] setText:obj.instructor];
    //Hilight date if it is in the range
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, y"];
    
    NSArray *dates = [Helpers splitDate:obj.dateRange];
    if (dates) {
        NSString *dateOneStr = [dates objectAtIndex:0];
        NSString *dateTwoStr = [dates objectAtIndex:1];
        NSDate *dateOne = [dateFormatter dateFromString:dateOneStr];
        NSDate *dateTwo = [dateFormatter dateFromString:dateTwoStr];
        if ([Helpers isDate:[NSDate date] inRangeFirstDate:dateOne lastDate:dateTwo])
            [[cell date] setTextColor:[cell location].textColor];
    }

    cell.catalogButton.tag = indexPath.row;
    cell.emailProfessor.tag = indexPath.row;
    cell.actionButton.tag = indexPath.row;
    
    cell.backgroundView = nil;
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }else {
        cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    [cell.catalogButton addTarget:self action:@selector(showCatalogInfo:) forControlEvents:UIControlEventTouchUpInside];
    [cell.actionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (obj.instructorEmail.length > 0) {
        [cell.emailProfessor addTarget:self action:@selector(sendEmail:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [cell.emailProfessor setHidden:YES];
    }
    
    
    return cell;
}

-(void)validateRegistration:(NSArray *)courses
{
    if (!courses) courses = coursesToRegister;
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Logging in..."];
    [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Retrieving PIN"];
        NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
        PCCObject *registrationTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
        NSString *pin = [dictionary objectForKey:registrationTerm.value];
        if (!pin) {
            NSString *pin = [[MyPurdueManager sharedInstance] getPinForSemester:registrationTerm.value];
            if (!pin || pin.length != 6) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[PCCHUDManager sharedInstance] dismissHUD];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Verification" message:[NSString stringWithFormat:@"What is your PIN for %@", registrationTerm.key] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [alertView show];
                    coursesToRegister = courses;
                });
            }else {
                //pin receieved from purdue
                NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
                if (!dictionary) dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
                [dictionary setObject:pin forKey:registrationTerm.value];
                [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kPinDictionary InDictionary:DataDictionaryUser];
                [self registerForCourses:courses];
            }
        }else {
            //we have the PIN saved and verified
            [self registerForCourses:courses];
        }
        
    }andFailure:^{
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Failed" success:NO];
    }];
}

-(void)registerForCourses:(NSArray *)courses
{
    [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Registering..."];
    NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
    PCCObject *registrationTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    PCFClassModel *course = [courses lastObject];
    if (course.term) registrationTerm.value = course.term;
    NSString *pin = [dictionary objectForKey:registrationTerm.value];
    
    [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
        NSDictionary *registrationDict = [[MyPurdueManager sharedInstance] canRegisterForTerm:registrationTerm.value withPin:pin];
        int response = [(NSNumber *)[registrationDict objectForKey:@"response"] intValue];
        if (response == PCCErrorOk) {
            NSString *query = [[MyPurdueManager sharedInstance] generateQueryString:[registrationDict objectForKey:@"data"] andRegisteringCourses:courses andDroppingCourses:nil];
            self.responseDictionary = [[MyPurdueManager sharedInstance] submitRegistrationChanges:query];
            NSNumber *response = [self.responseDictionary objectForKey:@"response"];
            int val = response.intValue;
            if (val == PCCErrorOk) {
                //register..this is a valid pin
                NSArray *schedule = [[MyPurdueManager sharedInstance] getCurrentScheduleViaDetailSchedule];
                [[PCCDataManager sharedInstance] setObject:schedule ForKey:registrationTerm.value InDictionary:DataDictionarySchedule];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Registered" success:YES];
                    [self.tableView reloadData];
                });
            }else if (val  == PCCErrorUnkownError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[PCCHUDManager sharedInstance] dismissHUD];
                    [self performSegueWithIdentifier:@"SegueRegistrationStatus" sender:self];
                });
            }
        }else if (response == PCCErrorUnkownError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PCCHUDManager sharedInstance] dismissHUD];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[registrationDict objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }else if (response == PCCErrorInvalidPin) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PCCHUDManager sharedInstance] dismissHUD];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Verification" message:[NSString stringWithFormat:@"What is your PIN for %@", registrationTerm.key] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
                [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField *textField = [alertView textFieldAtIndex:0];
                textField.keyboardType = UIKeyboardTypeNumberPad;
                [alertView show];
                coursesToRegister = courses;
            });
        }
    }andFailure:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueRegistrationStatus"]) {
        PCCRegistrationStatusViewViewController *vc = segue.destinationViewController;
        [vc setErrorArray:[self.responseDictionary objectForKey:@"errors"]];
    }
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    /*(if (buttonIndex == alertView.cancelButtonIndex) {
        [alertView show];
        return;
    }*/
    if (alertView.tag == 1) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            PCCPurdueLoginViewController *loginVC = (PCCPurdueLoginViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCPurdueLogin"];
            [self presentViewController:loginVC animated:YES completion:nil];
        }
        return;
    }
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    PCCObject *selectedObject = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (textField.text.length == 6) {
        NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
        if (!dictionary) dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        [[PCCHUDManager sharedInstance] performSelector:@selector(showHUDWithCaption:) withObject:@"Verifying..." afterDelay:0.7f];
        [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
            NSDictionary *registrationDict = [[MyPurdueManager sharedInstance] canRegisterForTerm:selectedObject.value withPin:textField.text];
            if ([registrationDict objectForKey:@"response"] == PCCErrorOk) {
                [dictionary setObject:textField.text forKey:selectedObject.value];
                [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kPinDictionary InDictionary:DataDictionaryUser];
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Valid PIN" success:YES];
                [self performSelector:@selector(registerForCourses:) withObject:coursesToRegister afterDelay:0.7f];
            }else {
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Incorrect PIN" success:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [alertView show];
                });
            }
        }andFailure:nil];
    }else {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:@"PIN must be 6 digits" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
    }
}

-(IBAction)actionButtonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    PCFClassModel *course;
    if (self.isFiltered) {
        course = [self.filteredDataSource objectAtIndex:button.tag];
    }else {
        course = [self.dataSource objectAtIndex:button.tag];
    }
    
        if ([button.titleLabel.text isEqualToString:@"Register"]) {
            if ([course.linkedID isEqualToString:@""]) {
                [self validateRegistration:@[course]];
            }else {
                //calculate linked sections and return
                self.linkedVC = [[PCCLinkedSectionViewController alloc] initWithTitle:@""];
                self.linkedVC.delegate = self;
                NSMutableArray *ds;
                /*if (self.isFiltered) {
                 ds = self.filteredDataSource.mutableCopy;
                 }else {
                 ds = self.dataSource.mutableCopy;
                 }*/
                ds =  self.dataSource.mutableCopy;
                
                [self.linkedVC setDataSource:ds];
                [self.linkedVC setCourse:course];
                if (self.searchType == searchCRN) {
                    if (linkedCourses.count > 0) {
                        [self.linkedVC setDataSource:linkedCourses.mutableCopy];
                    }else {
                        [[KPLightBoxManager sharedInstance] showLightBox];
                        [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Retrieving linked sections..."];
                        __weak PCCSearchResultsViewController *vc = self;
                        void (^block)() = ^{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[PCCHUDManager sharedInstance] dismissHUD];
                                if (linkedCourses.count > 0) {
                                    [vc.linkedVC setDataSource:linkedCourses.mutableCopy];
                                    [vc presentViewController:vc.linkedVC animated:YES completion:nil];
                                }
                            });
                        };
                        [self getLinkedCoursesWithBlock:block];
                        return;
                    }
                }
            [self presentViewController:self.linkedVC animated:YES completion:nil];
        }
    }
}
/*-(BOOL)containsIdenticalClass:(PCFClassModel *)class
{
    BOOL sameClasses = NO;
    NSMutableArray *arrayRegister = [PCCDataManager sharedInstance].arrayRegister;
    for (PCFClassModel *course in arrayRegister) {
        if ([course.courseNumber isEqualToString:class.courseNumber] && [course.classTitle isEqualToString:class.classTitle]) sameClasses = YES;
    }
    
    return sameClasses;
}*/

- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissNatGeoViewController];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCSearchResultsCell *newCell = (PCCSearchResultsCell *)cell;
    [newCell.activityIndicator startAnimating];
    if (retreievedValidTerms == NO) {
        [newCell.actionActivityIndicator startAnimating];
        [newCell.actionButton setAlpha:0.0f];
    }else {
        [newCell.actionActivityIndicator stopAnimating];
        [newCell.actionButton fadeIn];
    }
    [newCell.slots setAlpha:0.0f];
    [Helpers asyncronousBlockWithName:@"Get Slots" AndBlock:^{
        PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
        __block PCCCourseSlots *slots = [MyPurdueManager getCourseAvailabilityWithLink:class.classLink];
        dispatch_async(dispatch_get_main_queue(), ^{
            [newCell.activityIndicator stopAnimating];
            [newCell.slots setText:[NSString stringWithFormat:@"SLOTS: %@/%@", slots.enrolled, slots.capacity]];
            newCell.actionButton.enabled = allowAction;
            if (1 || slots.enrolled.intValue <= 0) {
                //no slots left
                [newCell setupCatcherWithCourse:class];
            }else {
                [newCell setupRegister];
                //[newCell setupCatcherWithCourse:class];
            }
        });
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isFiltered) return self.filteredDataSource.count;
    return self.dataSource.count;
}



#pragma mark Cell Methods
//1 on, 0 off
-(void)toggleFilter:(int)toggle
{
    if (!filterVC)  {
        filterVC = (PCCSearchResultsFilterViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCSearchResultsFilterViewController"];
        filterVC.titles = [Helpers getArrayOfScheduleTypes:self.dataSource];
        filterVC.savedItem = @"All";
    }
    
    if (toggle == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            filterVC.view.alpha = 0.0f;
            filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
            CGPoint placement = self.tableView.frame.origin;
            [self.view insertSubview:filterVC.view atIndex:0];
            [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.80f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                filterVC.view.frame = CGRectMake(placement.x, placement.y, filterVC.view.frame.size.width, filterVC.view.frame.size.height);
                filterVC.view.alpha = 1.0f;
                self.tableView.layer.transform = CATransform3DMakeTranslation(0, filterVC.view.frame.size.height, 0);
            }completion:^(BOOL finished) {
                if (!finished) { filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
                }else {
                    filterVC.view.frame = CGRectMake(placement.x, placement.y, filterVC.view.frame.size.width, filterVC.view.frame.size.height);
                    filterVC.view.alpha = 1.0f;
                    self.tableView.layer.transform = CATransform3DMakeTranslation(0, filterVC.view.frame.size.height, 0);
                }
            }];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            filterVC.view.alpha = 1.0f;
            [self.view addSubview:filterVC.view];
            [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.80f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                filterVC.view.alpha = 0.0f;
                filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
                self.tableView.layer.transform = CATransform3DIdentity;
            }completion:^(BOOL finished) {
                if (finished) {
                    filterVC.view.alpha = 1.0f;
                    filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
                    //reload the table now with new data
                    self.isFiltered = YES;
                    [self refreshData];
                }
            }];
        });
    }
}

-(void)refreshData
{
    BOOL showClosedCourses = filterVC.switchShowOpenCourses.selected;
    NSString *scheduleType = filterVC.savedItem;
    int fromHours = filterVC.fromLabel.text.intValue;
    int toHours = filterVC.toLabel.text.intValue;
    BOOL filterByTime = (filterVC.buttonToggleTime.tag == 1) ? YES : NO;
    unsigned int flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:filterVC.pickerBegin.date];
    NSDate *toTimeOnly = [calendar dateFromComponents:components];
    components = [calendar components:flags fromDate:filterVC.pickerEnd.date];
    NSDate* fromTimeOnly = [calendar dateFromComponents:components];
    
    NSMutableArray *filteredDataSource = [NSMutableArray arrayWithCapacity:3];
    for (PCFClassModel *courses in self.dataSource) {
        
        //filter by number of credits
        if (!(fromHours <= courses.credits.intValue && toHours >= courses.credits.intValue)) {
            continue;
        }
        
        //filter by schedule item
        if (![scheduleType isEqualToString:@"All"]) {
            if (![courses.scheduleType isEqualToString:scheduleType]) continue;
        }
        
        //filter by timer
        if (filterByTime == YES) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateFormat:@"h:mm a"];
            NSArray *time = [Helpers splitTime:courses.time];
             NSString *timeOneStr = [time objectAtIndex:0];
             NSString *timeTwoStr = [time objectAtIndex:1];
             NSDate *courseStartTime = [dateFormatter dateFromString:timeOneStr];
             NSDate *courseEndTime = [dateFormatter dateFromString:timeTwoStr];
            components = [calendar components:flags fromDate:courseStartTime];
            NSDate* courseStartTimeOnly = [calendar dateFromComponents:components];
            components = [calendar components:flags fromDate:courseEndTime];
            NSDate* courseEndTimeOnly = [calendar dateFromComponents:components];
            if (!([Helpers isDate:courseStartTimeOnly inRangeFirstDate:fromTimeOnly lastDate:toTimeOnly] && [Helpers isDate:courseEndTimeOnly inRangeFirstDate:fromTimeOnly lastDate:toTimeOnly])) {
                continue;
            }
        }
        [filteredDataSource addObject:courses];
    }
    
    self.filteredDataSource = filteredDataSource;
    [self.tableView reloadData];
    
}
-(IBAction)showFilters:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    NSInteger state = button.tag;
    int toggleValue = (state == 0) ? 1 : 0;
    if (toggleValue == 0) {
        [button setImage:[UIImage imageNamed:@"filter_normal.png"]];
    }else {
        [button setImage:[UIImage imageNamed:@"filter_selected.png"]];
    }
    button.tag = toggleValue;
    [self toggleFilter:toggleValue];
}

-(IBAction)dismissCatalog:(id)sender
{
    [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.90f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        catalogVC.view.center = CGPointMake(self.view.center.x, self.view.center.y + 50);
    }completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.25f delay:0.0f usingSpringWithDamping:0.90f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                catalogVC.view.center = CGPointMake(self.view.center.x, -500);
            }completion:^(BOOL finished) {
                [catalogVC.view removeFromSuperview];
                [[KPLightBoxManager sharedInstance] dismissLightBox];
            }];
        }
    }];
}
-(void)showCatalogInfo:(id)sender
{
    NSInteger row = [sender tag];
    [[KPLightBoxManager sharedInstance] showLightBox];
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
    
    [Helpers asyncronousBlockWithName:@"Retreiving Catalog Info" AndBlock:^{
        PCFClassModel *class = [self.dataSource objectAtIndex:row];
        NSString *catalogInfo = [MyPurdueManager getCatalogInformationWithLink:class.catalogLink];
        catalogVC = [[PCCCatalogViewController alloc] initWithNibName:@"PCCCatalogViewController" bundle:[NSBundle mainBundle]];
        catalogVC.body = catalogInfo;
        catalogVC.header = class.classTitle;
        catalogVC.vc = self;
        //[[KPLightBoxManager sharedInstance] dismissLightBox];
        [[PCCHUDManager sharedInstance] dismissHUDOnly];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[vc setTransitioningDelegate:self];
            catalogVC.view.alpha = 0.0f;
            CGPoint center = [UIApplication sharedApplication].keyWindow.center;
            catalogVC.view.center = CGPointMake(center.x, -800);
            [[UIApplication sharedApplication].keyWindow addSubview:catalogVC.view];
            [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:0.80f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                catalogVC.view.alpha = 0.85f;
                catalogVC.view.center = center;
            }completion:nil];
        });
    }];
    //do later

}

-(IBAction)sendEmail:(id)sender
{
    NSInteger row = [sender tag];
    PCFClassModel *course = [self.dataSource objectAtIndex:row];
    [Helpers sendEmail:course forViewController:self];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (error) NSLog(@"%@",error.description);
    [controller dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

#pragma mark - LinkedSection Delegate
-(void)completedRegistrationForClass:(BOOL)success courses:(NSArray *)courses;
{
    if (success) {
        [self validateRegistration:courses];
    }
}

/*
 self.basketVC = (PCCRegistrationBasketViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCRegistrationBasket"];
 self.basketVC.transitioningDelegate = self;
 
 [self presentViewController:self.basketVC animated:YES completion:^ {
 [self.tableView reloadData];
 }];
*/

@end
