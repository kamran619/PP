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

@interface PCCSearchResultsViewController ()
{
    PCCCatalogViewController *catalogVC;
    PCCSearchResultsFilterViewController *filterVC;
    NSArray *linkedCourses;
    
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
	// Do any additional setup after loading the view.
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
    cell.actionButton.enabled = YES;
    
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
            BOOL identical = [self containsIdenticalClass:course];
            if ([course.linkedID isEqualToString:@""]) {
                if (!identical) {
                    //no linked id..let register
                    if (![[PCCDataManager sharedInstance].arrayRegister containsObject:course]) {
                        [[PCCDataManager sharedInstance].arrayRegister addObject:course];
                        self.basketVC = (PCCRegistrationBasketViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCRegistrationBasket"];
                        self.basketVC.transitioningDelegate = self;
                        [self presentViewController:self.basketVC animated:YES completion:^ {
                            [button setEnabled:NO];
                            [self.tableView reloadData];
                        }];
                    }
                }else {
                    __weak PCCSearchResultsViewController *me = self;
                    self.deletionBlock = ^{
                        NSMutableArray *registerArray = [PCCDataManager sharedInstance].arrayRegister;
                        NSMutableArray *deleteArray = [NSMutableArray arrayWithCapacity:3];
                        for (PCFClassModel *class in registerArray) {
                            if ([course.courseNumber isEqualToString:class.courseNumber] && [course.classTitle isEqualToString:class.classTitle]) [deleteArray addObject:class];
                        }
                        
                        [registerArray removeObjectsInArray:deleteArray];
                        
                        [me actionButtonPressed:sender];
                    };
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Duplicate Course" message:@"You have already added another section of this course into your registration basket. Do you wish to remove the previous course and register for this one?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [alertView show];
                }
            }else {
                //calculate linked sections and return
                if (!identical) {
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
                }else {
                    //contains identical courses
                    __weak PCCSearchResultsViewController *me = self;
                    self.deletionBlock = ^{
                        NSMutableArray *registerArray = [PCCDataManager sharedInstance].arrayRegister;
                        NSMutableArray *deleteArray = [NSMutableArray arrayWithCapacity:3];
                        for (PCFClassModel *class in registerArray) {
                            if ([course.courseNumber isEqualToString:class.courseNumber] && [course.classTitle isEqualToString:class.classTitle]) [deleteArray addObject:class];
                        }
                        
                        [registerArray removeObjectsInArray:deleteArray];

                        [me actionButtonPressed:sender];
                    };
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Duplicate Course" message:@"You have already added another section of this course into your registration basket. Do you wish to remove the previous course and register for this one?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [alertView show];
                }
            }
        }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    if (self.deletionBlock) self.deletionBlock();
    
    
}
-(BOOL)containsIdenticalClass:(PCFClassModel *)class
{
    BOOL sameClasses = NO;
    NSMutableArray *arrayRegister = [PCCDataManager sharedInstance].arrayRegister;
    for (PCFClassModel *course in arrayRegister) {
        if ([course.courseNumber isEqualToString:class.courseNumber] && [course.classTitle isEqualToString:class.classTitle]) sameClasses = YES;
    }
    
    return sameClasses;
}

- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissNatGeoViewController];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCSearchResultsCell *newCell = (PCCSearchResultsCell *)cell;
    [newCell.activityIndicator startAnimating];
    [newCell.actionButton setAlpha:0.0f];
    [newCell.slots setAlpha:0.0f];
    [Helpers asyncronousBlockWithName:@"Get Slots" AndBlock:^{
        PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
        __block PCCCourseSlots *slots = [MyPurdueManager getCourseAvailabilityWithLink:class.classLink];
        dispatch_async(dispatch_get_main_queue(), ^{
            [newCell.activityIndicator stopAnimating];
            [newCell.slots setText:[NSString stringWithFormat:@"SLOTS: %@/%@", slots.enrolled, slots.capacity]];
            if (slots.enrolled.intValue <= 0) {
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
    UIButton *button = (UIButton *)sender;
    NSInteger state = button.tag;
    int toggleValue = (state == 0) ? 1 : 0;
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

    Class mailView = NSClassFromString(@"MFMailComposeViewController");
    if (mailView) {
        if ([mailView canSendMail]) {
            MFMailComposeViewController *mailSender = [[MFMailComposeViewController alloc] init];
            mailSender.mailComposeDelegate = self;
            NSArray *toRecipient = [NSArray arrayWithObject:[course instructorEmail]];
            [mailSender setToRecipients:toRecipient];
            NSString *emailBody = [[NSString alloc] initWithFormat:@"Professor %@,\n", [course instructor]];
            [mailSender setMessageBody:emailBody isHTML:NO];
            [mailSender setSubject:[NSString stringWithFormat:@"%@: %@", course.courseNumber, course.classTitle]];
            [self presentViewController:mailSender animated:YES completion:nil];
        }else {
            NSString *recipients = [[NSString alloc] initWithFormat:@"mailto:%@&subject=%@: %@", [course instructorEmail], [course courseNumber], course.classTitle];
            NSString *body = [[NSString alloc] initWithFormat:@"&body=Professor %@,\n", [course instructor]];
            NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }else {
        NSString *recipients = [[NSString alloc] initWithFormat:@"mailto:%@&subject=%@", [course instructorEmail], [course courseNumber]];
        NSString *body = [[NSString alloc] initWithFormat:@"&body=Professor %@,\n", [course instructor]];
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }

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
-(void)completedRegistrationForClass:(BOOL)success
{
    if (success) {
            self.basketVC = (PCCRegistrationBasketViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCRegistrationBasket"];
            self.basketVC.transitioningDelegate = self;
            
            [self presentViewController:self.basketVC animated:YES completion:^ {
                [self.tableView reloadData];
            }];
    }
}

@end
