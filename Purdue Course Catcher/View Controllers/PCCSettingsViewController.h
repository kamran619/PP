//
//  PCCSettingsViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/22/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCSettingsCell.h"
@interface PCCSettingsViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIButton *report;
@property (nonatomic, strong) IBOutlet UIButton *rate;
@property (nonatomic, strong) IBOutlet UIButton *reset;
@property (weak, nonatomic) IBOutlet UIButton *resetPressed;

@property (nonatomic, weak) IBOutlet PCCSettingsCell *settingsCell;


@end
