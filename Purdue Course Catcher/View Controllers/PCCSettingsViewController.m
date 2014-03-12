//
//  PCCSettingsViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/22/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSettingsViewController.h"
#import "PCCDataManager.h"
#import "PCCPurchaseViewController.h"
#import "PCCIAPHelper.h"

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateGoPro];
}

-(void)animateGoPro
{
    self.settingsCell.downArrow.alpha = 0.0f;
    self.settingsCell.downArrow.layer.transform = CATransform3DIdentity;
    [UIView animateWithDuration:0.45 delay:0.70f usingSpringWithDamping:0.5f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.settingsCell.downArrow.layer.transform = CATransform3DMakeTranslation(0, 15, 0);
        self.settingsCell.downArrow.alpha = 1.0f;
    }completion:^(BOOL finished) {
            if (finished) [self performSelector:_cmd withObject:nil afterDelay:3.5f];
    }];
}

-(IBAction)resetPressed:(id)sender
{
    [[PCCDataManager sharedInstance] resetData];
}
@end
