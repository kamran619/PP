//
//  PCCSideMenuViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/15/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSideMenuViewController.h"
#import "PCCMenuViewController.h"
#import "PCCCatcherViewController.h"
#import "Helpers.h"
#import "PCCDataManager.h"
#import "PCCPurdueLoginViewController.h"
#import "PCCRegistrationViewController.h"

@interface PCCSideMenuViewController ()

@end

@implementation PCCSideMenuViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)registerPressed:(id)sender {
        [self menuItemPressed:@"Register"];
}


- (IBAction)search:(id)sender {
    [self menuItemPressed:@"Search"];
}
- (IBAction)settings:(id)sender {
    [self menuItemPressed:@"Settings"];
}

- (IBAction)schedule:(id)sender {
        [self menuItemPressed:@"Schedule"];
}
- (IBAction)basket:(id)sender {
    [self menuItemPressed:@"Basket"];
}

-(void)menuItemPressed:(NSString *)itemName
{
    if ([itemName isEqualToString:@"Search"]) {
        PCCMenuViewController *menuViewController = (PCCMenuViewController *) self.parentViewController;
        [menuViewController replaceCenterViewControllerWithStoryboardIdentifier:@"PCCSearch"];
    }else if ([itemName isEqualToString:@"Schedule"]) {
        if (![Helpers getCredentials]) {
            PCCPurdueLoginViewController *vc = (PCCPurdueLoginViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCPurdueLogin"];
            vc.type = PCCTermTypeSchedule;
            [self presentViewController:vc animated:YES completion:nil];
        }else {
            PCCMenuViewController *menuViewController = (PCCMenuViewController *) self.parentViewController;
            [menuViewController replaceCenterViewControllerWithStoryboardIdentifier:@"PCCSchedule"];
        }
    }else if ([itemName isEqualToString:@"Register"]) {
            if (![Helpers getCredentials]) {
                PCCPurdueLoginViewController *vc = (PCCPurdueLoginViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCPurdueLogin"];
                vc.type = PCCTermTypeRegistration;
                [self presentViewController:vc animated:YES completion:nil];
            }else {
                PCCMenuViewController *menuViewController = (PCCMenuViewController *) self.parentViewController;
                [menuViewController replaceCenterViewControllerWithStoryboardIdentifier:@"PCCRegister"];
            }
        
    }else if ([itemName isEqualToString:@"Basket"]) {
        PCCMenuViewController *menuViewController = (PCCMenuViewController *) self.parentViewController;
        UINavigationController *controller = (UINavigationController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCCatcher"];
        if (![PCCDataManager sharedInstance].arrayBasket.count > 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Basket empty" message:@"Search for a course and then catch it." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        PCCCatcherViewController *catcherVC = [controller.childViewControllers lastObject];
        [catcherVC setDataSource:[PCCDataManager sharedInstance].arrayBasket];
        [menuViewController replaceCenterViewControllerWithViewController:controller animated:YES];
        
    }else if ([itemName isEqualToString:@"Store"]) {
        
    }else if ([itemName isEqualToString:@"Settings"]) {
    
    }
}
@end
