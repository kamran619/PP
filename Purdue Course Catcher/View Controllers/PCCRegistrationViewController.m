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

@interface PCCRegistrationViewController ()

@end

@implementation PCCRegistrationViewController
{

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
	// Do any additional setup after loading the view.
    [self checkRegistration];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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

#pragma mark PCCTerm Delegate
-(void)termPressed:(PCCObject *)term
{
    [[PCCDataManager sharedInstance] setObject:term ForKey:kPreferredRegistrationTerm InDictionary:DataDictionaryUser];
    [self checkRegistration];
}

#pragma mark UITableViewDelegate


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Classes to enroll in";
    }else {
        return @"Classes enrolled in";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        PCCRegistrationDropCell *cell = (PCCRegistrationDropCell *)[tableView dequeueReusableCellWithIdentifier:@"kRegistrationDropCell"];
        PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
        [cell.courseName setText:class.courseNumber];
        [cell.courseTitle setText:class.classTitle];
        [cell.credits setText:[NSString stringWithFormat:@"%@ credits", class.credits]];
        return cell;
    }else {
        PCCRegistrationAddCell *cell = (PCCRegistrationAddCell *)[tableView dequeueReusableCellWithIdentifier:@"kRegistrationAddCell"];
        PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
        [cell.courseName setText:class.courseNumber];
        [cell.courseTitle setText:class.classTitle];
        [cell.credits setText:[NSString stringWithFormat:@"%@ credits", class.credits]];
        [cell.removeButton setTag:indexPath.row];
        [cell.removeButton addTarget:self action:@selector(removePressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.removeButton setHidden:NO];
        [cell.credits setHidden:NO];
        
        if (![PCCDataManager sharedInstance].arrayRegister.count > 0) {
            [cell.courseName setText:@"NO CLASSES ADDED"];
            [cell.courseTitle setText:@"Search for classes and tap register to add here."];
            [cell.removeButton setHidden:YES];
            [cell.credits setHidden:YES];
        }
        
        return cell;
    }
    
    
}

-(void)removePressed:(id)sender
{
    NSMutableArray *array = [PCCDataManager sharedInstance].arrayRegister;
    [array removeObjectAtIndex:[sender tag]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sender tag] inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return self.dataSource.count;
    }else if (section == 0) {
        if (![PCCDataManager sharedInstance].arrayRegister || ![PCCDataManager sharedInstance].arrayRegister.count > 0) return 1;
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
