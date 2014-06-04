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
#import "PCCHUDManager.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    if ([[PCCDataManager sharedInstance].arrayPurchases containsObject:self.productToPurchase.productIdentifier]) {
        self.purchaseButton.enabled = NO;
        [self.purchaseButton setTitle:@"Already purchased"];
    }else {
        [self.purchaseButton setTitle:[NSString stringWithFormat:@"Purchase $%@", self.productToPurchase.price]];
    }
}

-(void)productPurchased:(NSNotification *)notification
{
    self.purchaseButton.enabled = NO;
}

-(IBAction)restorePressed:(id)sender
{
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Restoring..."];
    [[PCCIAPHelper sharedInstance] restoreCompletedTransactions];
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
