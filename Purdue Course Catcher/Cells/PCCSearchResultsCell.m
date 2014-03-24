//
//  PCCSearchResultsCell.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchResultsCell.h"
#import "DropAnimationController.h"
#import "PCCHUDManager.h"
#import "KPLightBoxManager.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "PCCCatalogViewController.h"
#import "PCFNetworkManager.h"
#import "PCCDataManager.h"

@implementation PCCSearchResultsCell


#define CUSTOM_COLOR [UIColor colorWithRed:0.85031 green:0.239408 blue:0.283582 alpha:1.0f];

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    self.contentDivider.backgroundColor = [UIColor blackColor];
    self.timeDivider.backgroundColor = CUSTOM_COLOR
}

- (IBAction)actionButtonPressed:(UIButton *)button {
    
    [PCFNetworkManager sharedInstance].delegate = self;
    
    if ([button.titleLabel.text isEqualToString:@"Catch"]) {
        NSArray *keys = [NSArray arrayWithObjects:@"crn", @"classLink", @"courseNumber" , @"term",  nil];
        NSArray *objects = [NSArray arrayWithObjects:self.course.CRN, self.course.classLink, self.course.courseNumber, self.course.term , nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [[PCFNetworkManager sharedInstance] setDelegate:self];
        [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandCatch withDictionary:dictionary];
    }else if ([button.titleLabel.text isEqualToString:@"Uncatch"]) {
        //uncatch
        NSArray *keys = [NSArray arrayWithObjects:@"crn" , @"term",  nil];
        NSArray *objects = [NSArray arrayWithObjects:self.course.CRN, self.course.term, nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [[PCFNetworkManager sharedInstance] setDelegate:self];
        [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandUnCatch withDictionary:dictionary];
    }

}


-(void)setupCatcherWithCourse:(PCFClassModel *)course
{
    if ([[PCCDataManager sharedInstance].arrayBasket containsObject:course] == YES) {
        [self.actionButton setTitle:@"Uncatch" forState:UIControlStateNormal];
    }else {
        [self.actionButton setTitle:@"Catch" forState:UIControlStateNormal];
    }
    
    [self.actionButton setEnabled:YES];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.actionButton.alpha = 1.0f;
        self.slots.alpha = 1.0f;
    }];
}

-(void)setupRegister
{
    if ([[PCCDataManager sharedInstance].arrayRegister containsObject:self.course]) {
        [self.actionButton setTitle:@"Register" forState:UIControlStateNormal];
        [self.actionButton setEnabled:NO];
    }else {
        [self.actionButton setTitle:@"Register" forState:UIControlStateNormal];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.actionButton.alpha = 1.0f;
        self.slots.alpha = 1.0f;
    }];
}

#pragma mark - PCFNetworkDelegate
-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success
{
    ServerCommand command;
    if (success) {
        command = [[responseDictionary objectForKey:@"command"] intValue];
    }else {
        command = [[requestDictionary objectForKey:@"command"] intValue];
    }
    
    switch (command) {
        case ServerCommandUnCatch:
            if (success) {
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Complete" success:YES];
                [[PCCDataManager sharedInstance].arrayBasket removeObject:self.course];
                [self.actionButton setTitle:@"Catch" forState:UIControlStateNormal];
            }else {    
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Error" success:NO];
            }
            break;
        case ServerCommandCatch:
            if (success) {
                [[PCCDataManager sharedInstance].arrayBasket addObject:self.course];
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Complete" success:YES];
                [self.actionButton setTitle:@"Uncatch" forState:UIControlStateNormal];
            }else {
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Error" success:NO];
            }
            break;
            
        default:
            break;
    }
    
    if (success) [[PCCDataManager sharedInstance] saveData];
}



@end
