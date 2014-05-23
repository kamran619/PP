//
//  PCCSearchFilterViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 5/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFAutoCompleteTextField.h"
#import "AKPickerView.h"
@interface PCCSearchFilterViewController : UIViewController <PCFAutoCompleteTextFieldDelegate, AKPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *courseTitleTextField;
@property (nonatomic, strong) IBOutlet UITextField *courseNumberTextField;
@property (nonatomic, strong) IBOutlet UIButton *mondayButton;
@property (nonatomic, strong) IBOutlet UIButton *tuesdayButton;
@property (nonatomic, strong) IBOutlet UIButton *wednesdayButton;
@property (nonatomic, strong) IBOutlet UIButton *thursdayButton;
@property (nonatomic, strong) IBOutlet UIButton *fridayButton;
@property (nonatomic, strong) IBOutlet UIButton *sundayButton;
@property (nonatomic, strong) IBOutlet UILabel *scheduleTypeLabel;
@property (nonatomic, strong) IBOutlet UILabel *instructorLabel;

@property (nonatomic, strong) PCFAutoCompleteTextField *professorTextField;
@property (nonatomic, strong) AKPickerView *scheduleTypePickerView;

@property (nonatomic, strong) NSArray *scheduleTypes;
@property (nonatomic, strong) PCCObject *savedItem;

- (IBAction)dayPressed:(UIButton *)sender;
@property (nonatomic, strong) NSMutableSet *setOfDays;
@end
