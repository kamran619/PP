//
//  PCCPurchaseViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/11/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCPurchaseViewController.h"
#import "PCCIAPHelper.h"
#import "PCCDataManager.h"

@interface PCCPurchaseViewController ()

@end

@implementation PCCPurchaseViewController

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
    //[self.purchasePressed addTarget:self action:@selector(purchaseProduct:) forControlEvents:UIControlEventTouchUpInside];
    if ([[PCCDataManager sharedInstance].arrayPurchases containsObject:self.productToPurchase.productIdentifier]) {
        self.purchaseButton.enabled = NO;
        //self.purchasePressed.enabled = NO;
        [self.purchaseButton setTitle:@"Already purchased"];
    }
	// Do any additional setup after loading the view.
}


-(void)purchaseProduct:(id)sender
{
    [[PCCIAPHelper sharedInstance] buyProduct:self.productToPurchase];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
