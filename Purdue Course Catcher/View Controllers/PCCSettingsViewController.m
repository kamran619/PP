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
#import "PCCNicknameTableViewController.h"
#import "PCFNetworkManager.h"
#import "PCCHUDManager.h"
#import "PCCFTUEViewController.h"

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
    BOOL upgraded;
    NSString *nickname;
    NSString *oldNickname;
    NSNumber *findByMajor;
    NSNumber *viewMySchedule;
    SKProduct *productToPurchase;
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
    upgraded = NO;
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
    
    NSDictionary *settings = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kSettings];
    nickname = [settings objectForKey:kNickname];
    //check settings and load them
    if (oldNickname && ![oldNickname isEqualToString:nickname]) [self showSaveButton];
    if (!nickname) nickname = [[[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kEducationInfoDictionary] objectForKey:kName];
    self.nicknameCell.detail.text = nickname;
    findByMajor = [settings objectForKey:kFindByMajor];
    viewMySchedule = [settings objectForKey:kViewMySchedule];
    if (!findByMajor) findByMajor = @YES;
    if (!viewMySchedule) viewMySchedule = @YES;
    
    self.findByMajorCell.detail.text = findByMajor.boolValue ? @"YES" : @"NO";
    self.viewMyScheduleCell.detail.text = viewMySchedule.boolValue ? @"YES" : @"NO";
    
    if ([[PCCDataManager sharedInstance].arrayPurchases containsObject:@"com.kamranpirwani.pcc.gopro"]) {
        self.upgradeCell.title.text = @"Upgraded to Pro";
        upgraded = YES;
    }
}

-(void)showSaveButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveSettings:)];
    [self.navigationItem setRightBarButtonItem:button animated:YES];
    /*[UIView animateWithDuration:0.25f animations:^{
        button.
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f animations:^{
            
        }];
    }];*/
}

-(void)saveSettings:(id)sender
{
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Saving..."];
    [PCFNetworkManager sharedInstance].delegate = self;
    NSDictionary *dictionary = @{kNickname: nickname, kFindByMajor: findByMajor, kViewMySchedule: viewMySchedule};
    [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandSettings withDictionary:dictionary];
}

-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success
{
    if (success) {
        NSMutableDictionary *settingsDictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kSettings];
        [settingsDictionary setObject:findByMajor forKey:kFindByMajor];
        [settingsDictionary setObject:viewMySchedule forKey:kViewMySchedule];
        [[PCCDataManager sharedInstance] setObject:settingsDictionary ForKey:kSettings InDictionary:DataDictionaryUser];
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Saved" success:YES];
    }else {
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Failed" success:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (upgraded) {
        self.upgradeCell.downArrow.layer.transform = CATransform3DMakeTranslation(0, 15, 0);
    }else {
        [self animateGoPro];
    }
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
        {
            [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
            [[PCCIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
                if (success) {
                    NSArray *_products = products;
                    for (SKProduct *product in _products) {
                        if ([product.productIdentifier isEqualToString:@"com.kamranpirwani.pcc.gopro"]) {
                            [[PCCHUDManager sharedInstance] dismissHUD];
                            productToPurchase = product;
                            [self performSegueWithIdentifier:@"SegueGoPro" sender:self];
                            
                        }
                    }
                }else {
                    [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Failed" success:NO];
                }
            }];
        }
            break;
        case sectionMyPurdue:
            if (loggedIn) {
                self.myPurdueCell.title.text = @"Username";
                self.myPurdueCell.detail.text = @"LOG IN";
                [Helpers setCurrentUser:nil];
                //zero everything out
                loggedIn = NO;
                PCCFTUEViewController *vc = (PCCFTUEViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCFTUEViewController"];
                [self presentViewController:vc animated:NO completion:nil];
            }
            //}else {
            //    [self performSegueWithIdentifier:@"SegueLoginViewController" sender:self];
            //}
            break;
            
        case sectionPrivacy:
            if (indexPath.row == 1) {
                [self showSaveButton];
                if ([findByMajor  isEqual: @YES]) {
                    //set to disallow
                    self.findByMajorCell.detail.text = @"NO";
                    findByMajor = @NO;
                    [self showSaveButton];
                }else {
                    //set to allow
                    self.findByMajorCell.detail.text = @"YES";
                    findByMajor = @YES;
            
                }
            }else if (indexPath.row == 2) {
                [self showSaveButton];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueNickname"]) {
        PCCNicknameTableViewController *vc = segue.destinationViewController;
        vc.nickname = self.nicknameCell.detail.text;
        oldNickname = self.nicknameCell.detail.text;
    }else if ([segue.identifier isEqualToString:@"SegueGoPro"]) {
        PCCPurchaseViewController *vc = segue.destinationViewController;
        vc.productToPurchase = productToPurchase;
    }
}

@end
