//
//  PCCRegistrationViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/20/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRegistrationViewController.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCDataManager.h"
#import "PCCObject.h"
#import "PCCTermViewController.h"
#import "UIView+Animations.h"
#import "PCCRegistrationDropCell.h"
#import "PCCRegistrationAddCell.h"
#import "PCFClassModel.h"

#import "KPLightBoxManager.h"
#import "PCCHUDManager.h"

#import "PCCRegistrationStatusViewViewController.h"

@interface PCCRegistrationViewController ()

@end

@implementation PCCRegistrationViewController
{
    NSMutableArray *droppedClasses;
}
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
    [self.submitButton addTarget:self action:@selector(submitTapped:)forControlEvents:UIControlEventTouchUpInside];
	// Do any additional setup after loading the view.
    [self checkRegistration];
}

-(void)initDropArray
{
    droppedClasses = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    for (int i = 0; i < self.dataSource.count; i++) {
        [droppedClasses insertObject:@NO atIndex:i];
    }
}

-(void)submitTapped:(id)sender
{
    [[KPLightBoxManager sharedInstance] showLightBox];
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Submitting..."];
    [Helpers asyncronousBlockWithName:@"Submit Registration" AndBlock:^{
        NSString *query = [self generateQueryString];
        self.responseDictionary = [[MyPurdueManager sharedInstance] submitRegistrationChanges:query];
        
        NSNumber *response = [self.responseDictionary objectForKey:@"response"];
        int val = response.intValue;
        if (val == PCCErrorOk) {
            [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Completed" andImage:[UIImage imageNamed:@"checkmark.png"]];
        }else if (val  == PCCErrorUnkownError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PCCHUDManager sharedInstance] dismissHUD];
                [self performSegueWithIdentifier:@"SegueRegistrationStatus" sender:self];
            });
            
        }
    }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueRegistrationStatus"]) {
        PCCRegistrationStatusViewViewController *vc = segue.destinationViewController;
        [vc setErrorArray:[self.responseDictionary objectForKey:@"errors"]];
    }
}
-(void)checkRegistration
{
    PCCObject *registrationTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredRegistrationTerm];
    
    void (^success)() = ^{
        [self.registrationHeader changeMessage:registrationTerm.key message:@"Logged in! Verifying pin..." image:nil];
        [Helpers asyncronousBlockWithName:@"Check valid pin" AndBlock:^{
            NSDictionary *response = [[MyPurdueManager sharedInstance] canRegisterForTerm:registrationTerm.value];
            NSNumber *canRegister = [response objectForKey:@"response"];
            if (canRegister.intValue == PCCErrorInvalidPin || canRegister.intValue == PCCErrorUnkownError) {
                [self.registrationHeader changeMessage:registrationTerm.key message:@"Invalid pin" image:@"failure.png"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect PIN" message:[NSString stringWithFormat:@"Please enter a correct PIN for %@", registrationTerm.key] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
                    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    textField.keyboardType = UIKeyboardTypeNumberPad;
                    [alertView show];
                });
            }else if (canRegister.intValue == PCCErrorOk) {
                self.dataSource = [response objectForKey:@"data"];
                [self initDropArray];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25f animations:^{
                        self.tableView.alpha = 1.0f;
                        self.submitButton.alpha = 1.0f;
                    }];
                    [self.tableView reloadData];
                    [self.registrationHeader changeMessage:registrationTerm.key message:@"Ready to register" image:@"checkmark.png"];
                });
            }
            [self.registrationHeader dismissHeaderWithDuration:0.75f];
        }];
    };
    
    if (!registrationTerm) {
        [self showTerms:nil];
    }else {
        self.tableView.alpha = 0.0f;
        self.submitButton.alpha = 0.0f;
        if (!self.registrationHeader) self.registrationHeader = [[PCCHeaderViewController alloc] initWithTerm:registrationTerm.value];
        [self.registrationHeader changeMessage:registrationTerm.key message:@"Logging into myPurdue" image:nil];
        [self.registrationHeader slideIn:self.view];
        [[MyPurdueManager sharedInstance] loginWithSuccessBlock:success andFailure:^{
            [self.registrationHeader changeMessage:registrationTerm.key message:@"Error logging into myPurdue" image:@"failure.png"];
        }];
    }
    
}

-(NSString *)generateQueryString
{
    PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    NSString *query = [NSString stringWithFormat:@"term_in=%@&RSTS_IN=DUMMY&assoc_term_in=DUMMY&CRN_IN=DUMMY&start_date_in=DUMMY&end_date_in=DUMMY&SUBJ=DUMMY&CRSE=DUMMY&SEC=DUMMY&LEVL=DUMMY&CRED=DUMMY&GMOD=DUMMY&TITLE=DUMMY&MESG=DUMMY&REG_BTN=DUMMY&MESG=DUMMY", term.value];
    for (int i = 0; i < self.dataSource.count; i++) {
        PCFClassModel *class = [self.dataSource objectAtIndex:i];
        NSArray *splitDate = [class.startDate componentsSeparatedByString:@"/"];
        NSString *startDate = [NSString stringWithFormat:@"%@%%2F%@%%2F%@", splitDate[0], splitDate[1], splitDate[2]];
        splitDate = [class.endDate componentsSeparatedByString:@"/"];
        NSString *endDate = [NSString stringWithFormat:@"%@%%2F%@%%2F%@", splitDate[0], splitDate[1], splitDate[2]];
        NSString *drop = ([[droppedClasses objectAtIndex:i] isEqualToNumber:@NO]) ? @"" : @"DW";
        
        NSArray *courseSplit = [class.courseNumber componentsSeparatedByString:@" "];
        NSString *subject = courseSplit[0];
        NSString *course = [NSString stringWithFormat:@"%@00", courseSplit[1]];
        NSString *gradeMode = [class.gradeMode stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *title = [class.classTitle stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *innerQuery = [NSString stringWithFormat:@"&RSTS_IN=%@&assoc_term_in=%@&CRN_IN=%@&start_date_in=%@&end_date_in=%@&SUBJ=%@&CRSE=%@&SEC=%@&LEVL=%@&CRED=++++%@&GMOD=%@&TITLE=%@&MESG=DUMMY", drop, class.term ,class.CRN, startDate, endDate, subject, course, class.sectionNum, class.level, class.credits, gradeMode, title];
        query = [query stringByAppendingString:innerQuery];
   
    }
    
    for (PCFClassModel *class in [PCCDataManager sharedInstance].arrayRegister) {
        NSString *innerQuery = [NSString stringWithFormat:@"&RSTS_IN=RW&CRN_IN=%@&assoc_term_in=&start_date_in=&end_date_in=", class.CRN];
        query = [query stringByAppendingString:innerQuery];
    }
    
    int count = 10 - (int)[PCCDataManager sharedInstance].arrayRegister.count;
    for (; count > 0; count--) {
        query = [query stringByAppendingString:@"&RSTS_IN=RW&CRN_IN=&assoc_term_in=&start_date_in=&end_date_in="];
    }
    
    query = [query stringByAppendingString:[NSString stringWithFormat:@"&regs_row=%lu&wait_row=0&add_row=10&REG_BTN=Submit+Changes", (unsigned long)self.dataSource.count]];
    return query;
}
#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 1) {
        if (buttonIndex == alertView.cancelButtonIndex) return;
        if (self.deletionBlock) {
             self.deletionBlock();
            self.deletionBlock = nil;
        }
    }else {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (textField.text.length > 0) {
            NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
            if (!dictionary) dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
            PCCObject *registrationTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredRegistrationTerm];
            [dictionary setObject:textField.text forKey:registrationTerm.value];
            [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kPinDictionary InDictionary:DataDictionaryUser];
            [self checkRegistration];
        }
    }
}

#pragma mark PCCTerm Delegate
-(void)termPressed:(PCCObject *)term
{
    [[PCCDataManager sharedInstance] setObject:term ForKey:kPreferredRegistrationTerm InDictionary:DataDictionaryUser];
    [self.tableView setAlpha:0.0f];
    [self checkRegistration];
}

#pragma mark UITableViewDelegate


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Attempting to Enroll in";
    }else {
        return @"Enrolled in";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return tableView.rowHeight;
    }else {
        return 84.0f;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        PCCRegistrationDropCell *cell = (PCCRegistrationDropCell *)[tableView dequeueReusableCellWithIdentifier:@"kRegistrationDropCell"];
        PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
        [cell.courseName setText:class.courseNumber];
        [cell.courseTitle setText:class.classTitle];
        [cell.dropButton setEnabled:YES];
        [cell.dropButton setTag:indexPath.row];
        [cell.dropButton addTarget:self action:@selector(dropPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.credits setText:[NSString stringWithFormat:@"%@ credits", class.credits]];
        if ([[class.status substringToIndex:4] isEqualToString:@"Drop"]) {
            [cell.dropButton setTitle:@"Web Dropped" forState:UIControlStateNormal];
            [cell.dropButton setEnabled:NO];
        }
        return cell;
    }else {
        PCCRegistrationAddCell *cell = (PCCRegistrationAddCell *)[tableView dequeueReusableCellWithIdentifier:@"kRegistrationAddCell"];
        
        if (![PCCDataManager sharedInstance].arrayRegister.count > 0) {
            [cell.courseName setText:@"NO CLASSES ADDED"];
            [cell.courseTitle setText:@"Search for classes and tap register"];
            [cell.removeButton setHidden:YES];
            [cell.scheduleType setHidden:YES];
            [cell.credits setHidden:YES];
        }else {
            PCFClassModel *class = [[PCCDataManager sharedInstance].arrayRegister objectAtIndex:indexPath.row];
            [cell.courseName setText:class.courseNumber];
            [cell.courseTitle setText:class.classTitle];
            [cell.credits setText:[NSString stringWithFormat:@"%@ credits", class.credits]];
            [cell.scheduleType setText:class.scheduleType];
            [cell.removeButton setTag:indexPath.row];
            [cell.removeButton addTarget:self action:@selector(removePressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.removeButton setHidden:NO];
            [cell.credits setHidden:NO];
            [cell.scheduleType setHidden:NO];
        }
        return cell;
    }
}

-(void)dropPressed:(id)sender
{
    NSNumber *value = [droppedClasses objectAtIndex:[sender tag]];
    if ([value isEqualToNumber:@NO]) {
        value = @YES;
        [sender setTitle:@"Undrop" forState:UIControlStateNormal];
    }else {
        value = @NO;
        [sender setTitle:@"Drop" forState:UIControlStateNormal];
    }
    
    [droppedClasses replaceObjectAtIndex:[sender tag] withObject:value];
}

-(void)removePressed:(id)sender
{
    NSMutableArray *array = [PCCDataManager sharedInstance].arrayRegister;
    PCFClassModel *class = [array objectAtIndex:[sender tag]];
    if ([class.linkedID isEqualToString:@""]) {
        [array removeObject:class];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else {
        __weak PCCRegistrationViewController *me = self;
        self.deletionBlock = ^{
            NSMutableArray *elementsToRemove = [NSMutableArray arrayWithCapacity:3];
            for (PCFClassModel *course in array) {
                if ([course.courseNumber isEqualToString:class.courseNumber] && [course.classTitle isEqualToString:class.classTitle]) [elementsToRemove addObject:course];
            }
            [array removeObjectsInArray:elementsToRemove.copy];
            [me.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"The course you are trying to remove has linked sections. If you remove this, the linked sections will be deleted as well. Do you wish to proceed?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert setTag:1];
        [alert show];
    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.dataSource.count;
    }else if (section == 0) {
        if (![PCCDataManager sharedInstance].arrayRegister || (![PCCDataManager sharedInstance].arrayRegister.count > 0)) return 1;
        return [PCCDataManager sharedInstance].arrayRegister.count;
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(IBAction)showTerms:(id)sender
{
    if (!self.navController) {
        self.navController = (UINavigationController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCTerm"];
        PCCTermViewController *termVC = [self.navController.childViewControllers lastObject];
        [termVC setType:PCCTermTypeRegistration];
        [termVC setDelgate:self];
    }
    
    [self presentViewController:self.navController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
