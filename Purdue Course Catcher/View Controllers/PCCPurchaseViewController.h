//
//  PCCPurchaseViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/11/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface PCCPurchaseViewController : UITableViewController

@property (nonatomic, strong) SKProduct *productToPurchase;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *purchaseButton;
-(IBAction)purchaseProduct:(id)sender;
@end
