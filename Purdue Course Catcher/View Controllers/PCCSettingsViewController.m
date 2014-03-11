//
//  PCCSettingsViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/22/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSettingsViewController.h"
#import "PCCDataManager.h"

@interface PCCSettingsViewController ()

@end

@implementation PCCSettingsViewController

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
}


-(IBAction)resetPressed:(id)sender
{
    [[PCCDataManager sharedInstance] resetData];
}
@end
