//
//  PCCScheduleViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCScheduleViewController.h"
#import "PCCDataManager.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "PCCObject.h"
#import "PCFClassModel.h"

#import "PCCScheduleCell.h"

#import "Helpers.h"

@interface PCCScheduleViewController ()

@end

@implementation PCCScheduleViewController
{
    NSString *preferredSchedule;
    NSArray *scheduleArray;
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
    [self loadSchedule];
    // Do any additional setup after loading the view from its nib.
}

-(void)fetchSchedule
{
    scheduleArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:preferredSchedule];
    if (scheduleArray != nil) {
        self.containerViewForSchedule.hidden = NO;
        //reload tableview data
        [self.tableView reloadData];
    }else {
        [self.activityIndicator startAnimating];
    }

    
    dispatch_queue_t task = dispatch_queue_create("Login to myPurdue", nil);
    dispatch_async(task, ^{
        if ([[MyPurdueManager sharedInstance] loginWithUsername:@"kpirwani" andPassword:@"!ScirockS619"] == NO) {
            NSLog(@"The login failed");
        }else {
            scheduleArray = [[MyPurdueManager sharedInstance] getCurrentScheduleViaDetailSchedule];
            [[PCCDataManager sharedInstance] setObject:scheduleArray ForKey:preferredSchedule InDictionary:DataDictionarySchedule];
            //reload data
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self.containerViewForSchedule setHidden:NO];
                [self.tableView reloadData];
            });
        }
    });
    
}

- (void)loadSchedule
{
    NSString *preferredScheduleToShow = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow];
    if (!preferredScheduleToShow) {
        if (![PCCDataManager sharedInstance].arrayTerms) {
            //terms have never been aggregated
            [self.setupContainerView setHidden:YES];
            [self.containerViewForSchedule setHidden:YES];
            [self.activityIndicator startAnimating];
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                [[PCCDataManager sharedInstance] setArrayTerms:[MyPurdueManager getMinimalTerms].mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self.setupContainerView setHidden:NO];
                    [self.pickerView reloadAllComponents];
                    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
                    preferredSchedule = obj.value;
                });
            }];
        }else {
            [self.setupContainerView setHidden:NO];
            [self.containerViewForSchedule setHidden:YES];
            [self.pickerView reloadAllComponents];
            PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
            preferredSchedule = obj.value;
            //we have terms..lets show them, and still make a network call
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
                if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pickerView reloadAllComponents];
                });
            }];
            
        }
    }else {
        //setup view
        self.setupContainerView.center = CGPointMake(320, 21);
        self.setupContainerView.hidden = YES;
        self.containerViewForSchedule.hidden = YES;
        [self addBarButtonItem];
        //we have terms..lets show them, and still make a network call
        [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
            NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
            if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickerView reloadAllComponents];
            });
        }];
        //we have the preferred schedule term saved..
        preferredSchedule = preferredScheduleToShow;
        scheduleArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:preferredSchedule];
        if (scheduleArray == nil) {
            [self fetchSchedule];
        }else {
            self.containerViewForSchedule.hidden = NO;
            //reload tableview data
            [self.tableView reloadData];
        }
    }
}

-(void)addBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(choosePreferredSchedule:)];
    [self.navItem setRightBarButtonItem:item animated:YES];
}

- (IBAction)choosePreferredSchedule:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, 1, 0.001);
        self.containerViewForSchedule.transform = t;
    }completion:^(BOOL finished) {
        self.containerViewForSchedule.hidden = YES;
        self.containerViewForSchedule.transform = CGAffineTransformIdentity;
        [self.setupContainerView setHidden:NO];
        self.setupContainerView.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:0.5f animations:^{
            self.setupContainerView.center = self.containerViewForSchedule.center;
            CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            self.setupContainerView.transform = t;
            [self.navItem setRightBarButtonItem:nil animated:YES];
        }];
    }];
}

- (IBAction)proceedToSchedule:(id)sender
{
    [[PCCDataManager sharedInstance] setObject:preferredSchedule ForKey:kPreferredScheduleToShow InDictionary:DataDictionaryUser];
    [UIView animateWithDuration:0.25f animations:^{
        self.setupContainerView.center = CGPointMake(320, 21);
        CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, .001, 0.001);
        self.setupContainerView.transform = t;
    }completion:^(BOOL finished) {
        self.setupContainerView.transform = CGAffineTransformIdentity;
        self.setupContainerView.hidden = YES;
        self.containerViewForSchedule.hidden = NO;
        self.containerViewForSchedule.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, .001);
        [self addBarButtonItem];
        [UIView animateWithDuration:0.5f animations:^{
            CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            self.containerViewForSchedule.transform = t;
        }completion:^(BOOL finished) {
            if (finished) {
                [self performSelectorOnMainThread:@selector(fetchSchedule) withObject:nil waitUntilDone:NO];
            }
        }];
    }];
}

#pragma mark Picker View Delegate

#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    preferredSchedule = obj.value;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    
    return obj.key;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

#pragma mark UIPickerView Data Source
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[PCCDataManager sharedInstance] arrayTerms] count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


#pragma mark UITableView Delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCFClassModel *obj = [scheduleArray objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"kScheduleCell";
    PCCScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSArray *timeArray = [Helpers splitDate:obj.time];
    if (timeArray) {
        [[cell startTime] setText:[timeArray objectAtIndex:0]];
        [[cell endTime] setText:[timeArray objectAtIndex:1]];
    }else {
        [[cell startTime] setText:@"TBA"];
        [[cell endTime] setText:@"TBA"];
    }

    [[cell location] setText:obj.classLocation];
    [[cell courseName] setText:obj.courseNumber];
    [[cell courseTitle] setText:obj.classTitle];
    [[cell courseType] setText:obj.scheduleType];
    [[cell courseSection] setText:obj.sectionNum];
    
    return cell;
    
}


#pragma mark UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return scheduleArray.count;
}

@end
