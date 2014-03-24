//
//  PCCSettingsViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/22/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCSettingsCell.h"
#import "PCFNetworkManager.h"

@interface PCCSettingsViewController : UITableViewController <PCFNetworkDelegate>

@property (nonatomic, strong) IBOutlet UIButton *report;
@property (nonatomic, strong) IBOutlet UIButton *rate;
@property (nonatomic, strong) IBOutlet UIButton *reset;
@property (weak, nonatomic) IBOutlet UIButton *resetPressed;

@property (nonatomic, weak) IBOutlet PCCSettingsCell *upgradeCell;
@property (nonatomic, weak) IBOutlet PCCSettingsCell *myPurdueCell;
@property (nonatomic, weak) IBOutlet PCCSettingsCell *nicknameCell;
@property (nonatomic, weak) IBOutlet PCCSettingsCell *findByMajorCell;
@property (nonatomic, weak) IBOutlet PCCSettingsCell *viewMyScheduleCell;

@end
