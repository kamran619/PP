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
#import "Helpers.h"

enum sections
{
    sectionUpgrade = 0,
    sectionMyPurdue,
    sectionPrivacy,
    sectionSupport
};

@interface PCCSettingsViewController ()
{
    BOOL loggedIn;
    NSNumber *findByMajor;
    NSNumber *viewMySchedule;
}
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initController];
}

-(BOOL)settingsChanged
{
    return NO;
}


-(void)initController
{
    //check if user is logged into purdue
    if ([Helpers isLoggedIn] == YES) {
        self.myPurdueCell.title.text = [[Helpers getCredentials] objectForKey:kUsername];
        self.myPurdueCell.detail.text = @"LOGOUT";
        loggedIn = YES;
    }else {
        self.myPurdueCell.title.text = @"Username";
        self.myPurdueCell.detail.text = @"LOG IN";
        loggedIn = NO;
    }
    
    //check settings and load them
    NSDictionary *settings = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kSettings];
    findByMajor = [settings objectForKey:kFindMeByMajor];
    viewMySchedule = [settings objectForKey:kViewMySchedule];
    if (!findByMajor) findByMajor = @YES;
    if (!viewMySchedule) viewMySchedule = @YES;
    
    self.findByMajorCell.detail.text = findByMajor.boolValue ? @"YES" : @"NO";
    self.viewMyScheduleCell.detail.text = viewMySchedule.boolValue ? @"YES" : @"NO";
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateGoPro];
}

-(void)animateGoPro
{
    self.upgradeCell.downArrow.alpha = 0.0f;
    self.upgradeCell.downArrow.layer.transform = CATransform3DIdentity;
    [UIView animateWithDuration:0.45 delay:0.70f usingSpringWithDamping:0.5f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.upgradeCell.downArrow.layer.transform = CATransform3DMakeTranslation(0, 15, 0);
        self.upgradeCell.downArrow.alpha = 1.0f;
    }completion:^(BOOL finished) {
            if (finished) [self performSelector:_cmd withObject:nil afterDelay:3.5f];
    }];
}

-(IBAction)resetPressed:(id)sender
{
    [[PCCDataManager sharedInstance] resetData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case sectionUpgrade:
            break;
        case sectionMyPurdue:
            if (loggedIn) {
                self.myPurdueCell.title.text = @"Username";
                self.myPurdueCell.detail.text = @"LOG IN";
                [[PCCDataManager sharedInstance].dictionaryUser removeObjectForKey:kCredentials];
                loggedIn = NO;
            }else {
                [self performSegueWithIdentifier:@"SegueLoginViewController" sender:self];
            }
            break;
            
        case sectionPrivacy:
            if (indexPath.row == 1) {
                if ([findByMajor  isEqual: @YES]) {
                    //set to disallow
                    self.findByMajorCell.detail.text = @"NO";
                    findByMajor = @NO;
                }else {
                    //set to allow
                    self.findByMajorCell.detail.text = @"YES";
                    findByMajor = @YES;
                }
            }else if (indexPath.row == 2) {
                if ([viewMySchedule  isEqual: @YES]) {
                    //set to disallow
                    self.viewMyScheduleCell.detail.text = @"NO";
                    viewMySchedule = @NO;
                }else {
                    //set to allow
                    self.viewMyScheduleCell.detail.text = @"YES";
                    viewMySchedule = @YES;
                }
            }
            break;
            
        case sectionSupport:
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
