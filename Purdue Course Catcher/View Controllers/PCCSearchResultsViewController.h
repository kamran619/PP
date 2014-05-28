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
#import "Helpers.h"
@class PCCRegistrationBasketViewController, PCCLinkedSectionViewController;

@interface PCCSearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, MFMailComposeViewControllerDelegate, LinkedSectionProtocol, UIAlertViewDelegate>

@property (nonatomic, strong) id<ADVAnimationController> animationController;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *filteredDataSource;
@property (nonatomic, assign) BOOL isFiltered;
@property (nonatomic, strong) PCCRegistrationBasketViewController *basketVC;
@property (nonatomic, strong) PCCLinkedSectionViewController *linkedVC;
@property (nonatomic, assign) search searchType;
@property (nonatomic, strong) void(^deletionBlock)();
@property (nonatomic, strong) NSDictionary *responseDictionary;

-(void)completedRegistrationForClass:(BOOL)success courses:(NSArray *)courses;
-(void)validateRegistration:(NSArray *)courses;
-(void)registerForCourses:(NSArray *)courses;
@end
