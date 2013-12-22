//
//  PCCSideMenuViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/15/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSideMenuViewController.h"
#import "PCCMenuViewController.h"
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

- (IBAction)search:(id)sender {
    [self menuItemPressed:@"Search"];
}
- (IBAction)settings:(id)sender {
    [self menuItemPressed:@"Settings"];
}

- (IBAction)schedule:(id)sender {
    [self menuItemPressed:@"Schedule"];
}

-(void)menuItemPressed:(NSString *)itemName
{
    if ([itemName isEqualToString:@"Search"]) {
        PCCMenuViewController *menuViewController = (PCCMenuViewController *) self.parentViewController;
        [menuViewController replaceCenterViewControllerWithStoryboardIdentifier:@"PCCSearch"];
    }else if ([itemName isEqualToString:@"Schedule"]) {
        PCCMenuViewController *menuViewController = (PCCMenuViewController *) self.parentViewController;
        [menuViewController replaceCenterViewControllerWithStoryboardIdentifier:@"PCCSchedule"];
    }else if ([itemName isEqualToString:@"Ratings"]) {
        
    }else if ([itemName isEqualToString:@"Basket"]) {
        
    }else if ([itemName isEqualToString:@"Store"]) {
        
    }else if ([itemName isEqualToString:@"Settings"]) {
    
    }
    
}
@end
