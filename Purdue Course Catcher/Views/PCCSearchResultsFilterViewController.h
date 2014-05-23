//
//  PCCSearchFilterView.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 5/15/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKPickerView.h"
@interface PCCSearchResultsFilterViewController : UIViewController <AKPickerViewDelegate>

@property (nonatomic, strong) AKPickerView *pickerViewCourseType;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UISwitch *switchShowOpenCourses;
@property (nonatomic, strong) IBOutlet UILabel *labelCourseTypes;
@property (nonatomic, strong) IBOutlet UIStepper *stepperFrom;
@property (nonatomic, strong) IBOutlet UIStepper *stepperTo;
@property (nonatomic, strong) IBOutlet UIButton *buttonToggleTime;
@property (nonatomic, strong) IBOutlet UILabel *fromLabel;
@property (nonatomic, strong) IBOutlet UILabel *toLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UIDatePicker *pickerBegin;
@property (nonatomic, strong) IBOutlet UIDatePicker *pickerEnd;
@property (nonatomic, strong) IBOutlet UIView *viewBlocker;
@property (nonatomic, strong) IBOutlet UIImageView *timeImage;

@property (nonatomic, strong) NSString *savedItem;
@end
