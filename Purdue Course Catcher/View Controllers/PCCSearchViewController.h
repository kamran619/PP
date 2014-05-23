//
//  PCCSearchViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFAutoCompleteTextField.h"
#import "PCCSearchFilterViewController.h"
#import "ADVAnimationController.h"
#import "PCCTermViewController.h"

@interface PCCSearchViewController : UIViewController <UIScrollViewDelegate, PCFAutoCompleteTextFieldDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, PCCTermDelegate>

-(IBAction)valueChanged:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *fadeText;


@property (nonatomic, strong) IBOutlet UIView *containerViewSearch;


@property (nonatomic, strong) IBOutlet UILabel *detailLabel;

@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, assign) BOOL isFiltered;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) PCFAutoCompleteTextField *autoCompleteTextField;

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *termButton;

@property (nonatomic, strong) id<ADVAnimationController> animationController;

@end
