//
//  PCCCatalogViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCSearchResultsViewController.h"
@interface PCCCatalogViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *labelBody;
@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *header;

@property (nonatomic, strong) PCCSearchResultsViewController *vc;
@end
