//
//  PCCSearchFilterView.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 5/15/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchFilterViewController.h"
#import "AKPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "Helpers.h"

@implementation PCCSearchFilterViewController

-(void)viewDidLoad
{
    if (self) {
        // Initialization code
        self.pickerViewCourseType = [[AKPickerView alloc] initWithFrame:CGRectMake(-10, self.labelCourseTypes.frame.origin.y + 10, 320, 64)];
        self.pickerViewCourseType.delegate = self;
        self.buttonToggleTime.layer.cornerRadius = 9.0f;
        self.buttonToggleTime.layer.borderColor = [Helpers purdueColor:PurdueColorDarkGrey].CGColor;
        self.buttonToggleTime.titleLabel.textColor = [Helpers purdueColor:PurdueColorDarkGrey];
        self.buttonToggleTime.layer.borderWidth = 1.0f;
        self.stepperFrom.layer.borderWidth = 1.0f;
        self.stepperTo.layer.borderWidth = 1.0f;
        [self.view addSubview:self.pickerViewCourseType];
        self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.view.layer.borderWidth = 2.0f;
        self.switchShowOpenCourses.transform = CGAffineTransformMakeScale(0.70, .70);
        [self.pickerViewCourseType reloadData];
        
        
    }

}
- (IBAction)switchChanged:(id)sender {
    
}

- (IBAction)segmentChanged:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        //show from
        self.pickerBegin.alpha = 1.0f;
        self.pickerEnd.alpha = 0.0f;
    }else {
        //show to
        self.pickerEnd.alpha = 1.0f;
        self.pickerBegin.alpha = 0.0f;
    }
}
-(IBAction)valueChanged:(UIStepper *)sender
{
    int value = (int)[sender value];
    
    if ([sender tag] == 0) {
        //from
        self.fromLabel.text = [NSString stringWithFormat:@"%d", value];
    }else {
        //to
        self.toLabel.text = [NSString stringWithFormat:@"%d", value];
    }
}

-(IBAction)showTimePushed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([sender tag] == 0) {
        //reveal the hidden info
        button.tag = 1;
        [UIView animateWithDuration:0.25f animations:^{
            self.viewBlocker.alpha = 1.0f;
            self.timeImage.alpha = 1.0f;
        }];
    
    }else {
        //hide the info
        button.tag = 0;
        [UIView animateWithDuration:0.25f animations:^{
            //227,174,35
            self.viewBlocker.alpha = 0.0f;
            self.timeImage.alpha = 0.0f;

        }];
    }
}
- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView
{
	return [self.titles count];
}

- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item
{
	return self.titles[item];
}

- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item
{
	self.savedItem = self.titles[item];
}


@end
