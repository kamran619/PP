//
//  PCCStoreViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/10/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCStoreViewController.h"
#import "PCCIAPHelper.h"
#import "PCCStoreCell.h"
#import "PCCDataManager.h"
#import "PCCPurchaseViewController.h"
#import "PCCHUDManager.h"

@interface PCCStoreViewController () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}
@end

@implementation PCCStoreViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -20) animated:NO];
    [self reload];

    //get rid of extranneous cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PCCPurchaseViewController *vc = segue.destinationViewController;
    [vc setProductToPurchase:_products[[sender row]]];
}

- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[PCCIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
    
}

- (IBAction)restorePressed:(id)sender {
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Restoring..."];
    [[PCCIAPHelper sharedInstance] restoreCompletedTransactions];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCStoreCell *cell = (PCCStoreCell *)[tableView dequeueReusableCellWithIdentifier:@"kStoreCell" forIndexPath:indexPath];
    
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    cell.title.text = product.localizedTitle;
    
    [_priceFormatter setLocale:product.priceLocale];
    cell.price.text = [_priceFormatter stringFromNumber:product.price];
    
    if ([[PCCIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detail.text = @"Purchased!";
        cell.backgroundView = nil;
        cell.accessoryView = nil;
    } else {
        cell.backgroundColor = [UIColor clearColor];
        //[cell.purchaseButton setTitle:@"Buy" forState:UIControlStateNormal];
        //[cell.purchaseButton setTag:indexPath.row];
        //cell.purchaseButton.hidden = NO;
        //[cell.purchaseButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.tag = indexPath.row;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = (SKProduct *) _products[indexPath.row];
    if ([product.productIdentifier isEqualToString:@"com.kamranpirwani.pcc.removeads"]) {
        [self performSegueWithIdentifier:@"SegueRemoveAds" sender:indexPath];
    }else if ([product.productIdentifier isEqualToString:@"com.kamranpirwani.pcc.gopro"]) {
        [self performSegueWithIdentifier:@"SegueGoPro" sender:indexPath];
    }
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[PCCIAPHelper sharedInstance] buyProduct:product];
    
}

@end
