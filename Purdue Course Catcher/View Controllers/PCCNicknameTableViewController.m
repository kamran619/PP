//
//  PCCNicknameTableViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/15/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCNicknameTableViewController.h"
#import "PCCDataManager.h"

@interface PCCNicknameTableViewController ()

@end

@implementation PCCNicknameTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)]
    ;
    [self.tapGesture setNumberOfTapsRequired:1];
    [self.tapGesture setNumberOfTouchesRequired:1];
    [self.tableView addGestureRecognizer:self.tapGesture];
    
    self.nicknameCell.textField.text = self.nickname;
    //self.nicknameCell.textField.delegate = self;
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![self.nickname isEqualToString:self.nicknameCell.textField.text]) {
        NSMutableDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kSettings];
        if (!dictionary) {
            dictionary = [[NSMutableDictionary alloc] initWithCapacity:3];
            [dictionary setObject:@YES forKey:kFindByMajor];
            [dictionary setObject:@YES forKey:kViewMySchedule];
        }
        [dictionary setObject:self.nicknameCell.textField.text forKey:kNickname];
        [[PCCDataManager sharedInstance] setObject:dictionary ForKey:kSettings InDictionary:DataDictionaryUser];
    }
    
}

-(void)tapped:(id)sender
{
    [self.nicknameCell.textField resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
