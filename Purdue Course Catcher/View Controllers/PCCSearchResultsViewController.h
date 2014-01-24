//
//  PCCSearchResultsViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADVAnimationController.h"
#import <MessageUI/MessageUI.h>
#import "PCFNetworkManager.h"
#import "PCCLinkedSectionViewController.h"

@class PCCRegistrationBasketViewController, PCCLinkedSectionViewController;

@interface PCCSearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, MFMailComposeViewControllerDelegate, LinkedSectionProtocol>

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) PCCRegistrationBasketViewController *basketVC;
@property (nonatomic, strong) PCCLinkedSectionViewController *linkedVC;

-(void)completedRegistrationForClass:(BOOL)success;
@end
