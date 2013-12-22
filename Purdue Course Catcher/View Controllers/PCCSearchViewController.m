//
//  PCCSearchViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchViewController.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "PCCObject.h"
#import "PCCDataManager.h"

#define CENTER_FRAME CGPointMake(320, 21);
@interface PCCSearchViewController ()

@end

@implementation PCCSearchViewController
{
    NSString *myPreferredSearchTerm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView
{
    NSString *preferredSearchTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    if (!preferredSearchTerm) {
        if (![PCCDataManager sharedInstance].arrayTerms) {
            //terms have never been aggregated
            [self.containerView setHidden:YES];
            [self.containerViewSearch setHidden:YES];
            [self.activityIndicator startAnimating];
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                [[PCCDataManager sharedInstance] setArrayTerms:[MyPurdueManager getMinimalTerms].mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self.containerView setHidden:NO];
                    [self.pickerView reloadAllComponents];
                    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
                    myPreferredSearchTerm = obj.value;
                });
            }];
        }else {
            [self.containerView setHidden:NO];
            [self.containerViewSearch setHidden:YES];
            [self.pickerView reloadAllComponents];
            //we have terms..lets show them, and still make a network call
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
                if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pickerView reloadAllComponents];
                    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
                    myPreferredSearchTerm = obj.value;
                });
            }];

        }
    }else {
        //we have the preferred search term saved..lets let them directly search
        myPreferredSearchTerm = preferredSearchTerm;
        self.containerView.center = CENTER_FRAME;
        self.containerView.hidden = YES;
        self.containerViewSearch.hidden = NO;
        [self addBarButtonItem];
        //we have terms..lets show them, and still make a network call
        [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
            NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
            if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickerView reloadAllComponents];
            });
        }];
    }
}

-(void)addBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(choosePreferredTerm:)];
    [self.navItem setRightBarButtonItem:item animated:YES];
}

- (IBAction)choosePreferredTerm:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        self.containerViewSearch.transform = CGAffineTransformMakeScale(1, .001);
    }completion:^(BOOL finished) {
        self.containerViewSearch.hidden = YES;
        self.containerViewSearch.transform = CGAffineTransformIdentity;
        [self.containerView setHidden:NO];
        self.containerView.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:0.5f animations:^{
            self.containerView.center = self.containerViewSearch.center;
            self.containerView.transform = CGAffineTransformMakeScale(1, 1);
            [self.navItem setRightBarButtonItem:nil animated:YES];
        }];
    }];
}

- (IBAction)proceedToSearch:(id)sender
{
    [[PCCDataManager sharedInstance] setObject:myPreferredSearchTerm ForKey:kPreferredSearchTerm InDictionary:DataDictionaryUser];
    [UIView animateWithDuration:0.25f animations:^{
        self.containerView.center = CENTER_FRAME;
            self.containerView.transform = CGAffineTransformMakeScale(.001, .001);
    }completion:^(BOOL finished) {
        self.containerView.transform = CGAffineTransformIdentity;
        self.containerView.hidden = YES;
        self.containerViewSearch.hidden = NO;
        self.containerViewSearch.transform = CGAffineTransformMakeScale(1, .001);
        [self addBarButtonItem];
        [UIView animateWithDuration:0.5f animations:^{
            self.containerViewSearch.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    myPreferredSearchTerm = obj.value;
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





@end
