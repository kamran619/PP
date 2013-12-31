//
//  PCCSearchViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFAutoCompleteTextField.h"
#import "ADVAnimationController.h"
@interface PCCSearchViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, PCFAutoCompleteTextFieldDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

-(IBAction)valueChanged:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *fadeText;

@property (nonatomic, strong) IBOutlet UIView *containerViewSearch;
@property (nonatomic, strong) IBOutlet UIView *containerView;

@property(nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIButton *buttonNext;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;


@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;

@property (nonatomic, strong) PCFAutoCompleteTextField *autoCompleteTextField;
@property (nonatomic, strong) PCFAutoCompleteTextField *professorTextField;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;


@property (nonatomic, strong) IBOutlet UIView *advancedView;

//in view
@property (nonatomic, strong) IBOutlet UITextField *courseTitleTextField;
@property (nonatomic, strong) IBOutlet UITextField *courseNumberTextField;
@property (nonatomic, strong) IBOutlet UIButton *mondayButton;
@property (nonatomic, strong) IBOutlet UIButton *tuesdayButton;
@property (nonatomic, strong) IBOutlet UIButton *wednesdayButton;
@property (nonatomic, strong) IBOutlet UIButton *thursdayButton;
@property (nonatomic, strong) IBOutlet UIButton *fridayButton;
@property (nonatomic, strong) IBOutlet UIButton *sundayButton;

@property (nonatomic, strong) id<ADVAnimationController> animationController;

- (IBAction)dayPressed:(UIButton *)sender;
@property (nonatomic, strong) NSMutableSet *setOfDays;

@end
