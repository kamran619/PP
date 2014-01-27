//
//  PCCTermViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/18/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCTermViewController.h"
#import "PCCObject.h"
#import "Helpers.h"
#import "PCCDataManager.h"
#import "MyPurdueManager.h"
#import "UIView+Animations.h"



@interface PCCTermViewController ()
{
    PCCObject *selectedObject;
}
@end

@implementation PCCTermViewController

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
    [self loadData];
    [self configureDismissButton];
	// Do any additional setup after loading the view.
}

-(void)configureDismissButton
{
    BOOL show = YES;
    
    if (self.type == PCCTermTypeSearch) {
        if (![[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm]) show = NO;
    }else if (self.type == PCCTermTypeSchedule) {
        if (![[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow]) show = NO;
    }else if (self.type == PCCTermTypeRegistration) {
        if (![[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredRegistrationTerm]) show = NO;
    }
    
    if (!show) self.navigationItem.leftBarButtonItem = nil;
}
-(void)setHeaderForTermType:(PCCTermType)type
{
    if (type == PCCTermTypeSearch) {
        [self.headerLabel setText:@"Choose a semester to search in:"];
    }else if (type == PCCTermTypeSchedule) {
        [self.headerLabel setText:@"Choose a semester to view your schedule for:"];
    }else if (type == PCCTermTypeRegistration) {
        [self.headerLabel setText:@"Choose a semester to register for:"];
    }else {
        [self.headerLabel setText:@"The myPurdue portal is currently unavailable!"];
    }
}
-(void)loadData
{
    [self setHeaderForTermType:self.type];
    
    if (!self.dataSource) {
        [self.headerLabel setAlpha:0.0f];
        [self.pickerView setAlpha:0.0f];
        [self.doneButton setAlpha:0.0f];
        [self.activityIndicator startAnimating];
        
        if (self.type == PCCTermTypeRegistration) {
            //get reg terms
            [Helpers asyncronousBlockWithName:@"Get Registration Terms" AndBlock:^{
                [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
                    self.dataSource = [[MyPurdueManager sharedInstance] getRegistrationTerms].mutableCopy;
                    PCCObject *firstObject = [self.dataSource objectAtIndex:0];
                    selectedObject = [[PCCObject alloc] initWithKey:firstObject.key AndValue:firstObject.value];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        [self.headerLabel fadeIn];
                        [self.pickerView fadeIn];
                        [self.doneButton fadeIn];
                        [self.pickerView reloadAllComponents];
                    });
                }andFailure:nil];
                
                }];
        }else {
            //get other terms
            if (![PCCDataManager sharedInstance].arrayTerms) {
                //terms have never been aggregated
                [self.activityIndicator startAnimating];
                [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                    NSArray *terms = [MyPurdueManager getMinimalTerms];
                    if (terms.count > 0) {
                        self.dataSource = terms.mutableCopy;
                        PCCObject *firstObject = [self.dataSource objectAtIndex:0];
                        selectedObject = [[PCCObject alloc] initWithKey:firstObject.key AndValue:firstObject.value];
                        [[PCCDataManager sharedInstance] setArrayTerms:terms.mutableCopy];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicator stopAnimating];
                            [self.headerLabel fadeIn];
                            [self.pickerView fadeIn];
                            [self.doneButton fadeIn];
                            [self.pickerView reloadAllComponents];
                        });
                    }else {
                        //error getting terms. show another screen
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.activityIndicator stopAnimating];
                            [self.pickerView fadeOut];
                            [self setHeaderForTermType:PCCTermTypeError];
                            self.doneButton.tag = 1;
                            [self.doneButton setTitle:@"Retry" forState:UIControlStateNormal];
                            [self.headerLabel fadeIn];
                            [self.pickerView fadeIn];
                            [self.doneButton fadeIn];
                        });
                    }
                }];
            }else {
                self.dataSource = [PCCDataManager sharedInstance].arrayTerms;
                //lets still make a network call and update the data
                [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                    NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
                    [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
                }];
            }
        }
    }else {
        PCCObject *firstObject = [self.dataSource objectAtIndex:0];
        selectedObject = [[PCCObject alloc] initWithKey:firstObject.key AndValue:firstObject.value];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)doneButtonPressed:(id)sender
{
    if (self.doneButton.tag == 1) {
        //an error occured getting the terms
        [self.headerLabel setAlpha:0.0f];
        [self.doneButton setAlpha:0.0f];
        [self.activityIndicator startAnimating];

        [Helpers asyncronousBlockWithName:@"Retry Terms" AndBlock:^{
            NSArray *terms = [MyPurdueManager getMinimalTerms];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (terms.count > 0) {
                    [[PCCDataManager sharedInstance] setArrayTerms:terms.mutableCopy];
                    self.doneButton.tag = 0;
                    [self setHeaderForTermType:self.type];
                    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
                    [self.activityIndicator stopAnimating];
                    [self.headerLabel fadeIn];
                    [self.doneButton fadeIn];
                    [self.pickerView fadeIn];
                    [self.pickerView reloadAllComponents];
                }else {
                    
                    [self.activityIndicator stopAnimating];
                    [self.headerLabel fadeIn];
                    [self.doneButton fadeIn];
                }
            });
        }];
        return;
    }
    
    if ([self.delgate respondsToSelector:@selector(termPressed:)]) {
        if (self.type == PCCTermTypeRegistration) {
            NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
            NSString *pin = [dictionary objectForKey:selectedObject.value];
            if (!pin) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Verification" message:[NSString stringWithFormat:@"What is your PIN for %@", selectedObject.key] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Enter", nil];
                [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
                UITextField *textField = [alertView textFieldAtIndex:0];
                textField.keyboardType = UIKeyboardTypeNumberPad;
                [alertView show];
            }else {
                [self.delgate termPressed:selectedObject];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }else {
            [self.delgate termPressed:selectedObject];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        [alertView show];
        return;
    }
    
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (textField.text.length > 0) {
        NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPinDictionary];
        if (!dictionary) dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        [dictionary setObject:textField.text forKey:selectedObject.value];
        [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kPinDictionary InDictionary:DataDictionaryUser];
        [self.delgate termPressed:selectedObject];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [alertView show];
    }
}
#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PCCObject *tempObject = [self.dataSource objectAtIndex:row];
    selectedObject.key = tempObject.key;
    selectedObject.value = tempObject.value;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PCCObject *obj = [self.dataSource objectAtIndex:row];
    return obj.key;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

#pragma mark UIPickerView Data Source
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSource.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


@end
