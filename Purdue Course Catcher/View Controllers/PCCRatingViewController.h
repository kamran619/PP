//
//  PCCRatingViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/4/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFNetworkManager.h"

@interface PCCRatingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, PCFNetworkDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success;
@end
