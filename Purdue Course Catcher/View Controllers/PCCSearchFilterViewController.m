//
//  PCCSearchFilterViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 5/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchFilterViewController.h"
#import "Helpers.h"
#import "PCCDataManager.h"

@interface PCCSearchFilterViewController ()

@end

#define BUTTON_CORNER_RADIUS 3.0f

@implementation PCCSearchFilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initController];
    // Do any additional setup after loading the view.
}

-(void)initController
{
    self.mondayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.mondayButton.layer.borderWidth = 1.0f;
    self.mondayButton.layer.borderColor = [Helpers purdueColor:PurdueColorYellow].CGColor;
    self.tuesdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.tuesdayButton.layer.borderWidth = 1.0f;
    self.tuesdayButton.layer.borderColor = [Helpers purdueColor:PurdueColorYellow].CGColor;
    self.wednesdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.wednesdayButton.layer.borderWidth = 1.0f;
    self.wednesdayButton.layer.borderColor = [Helpers purdueColor:PurdueColorYellow].CGColor;
    self.thursdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.thursdayButton.layer.borderWidth = 1.0f;
    self.thursdayButton.layer.borderColor = [Helpers purdueColor:PurdueColorYellow].CGColor;
    self.fridayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.fridayButton.layer.borderWidth = 1.0f;
    self.fridayButton.layer.borderColor = [Helpers purdueColor:PurdueColorYellow].CGColor;
    self.sundayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.sundayButton.layer.borderWidth = 1.0f;
    self.sundayButton.layer.borderColor = [Helpers purdueColor:PurdueColorYellow].CGColor;
    

    CGRect profFrame = CGRectOffset(self.instructorLabel.frame, 0, 30);
    profFrame.size.height = 30;
    profFrame.size.width = 280;
    self.professorTextField = [[PCFAutoCompleteTextField alloc] initWithFrame:profFrame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
    NSArray *professorDataSource = [PCCDataManager sharedInstance].arrayProfessors;
    [self.professorTextField setDataToAutoComplete:professorDataSource.copy];
    [self.professorTextField.textField setFont:[UIFont systemFontOfSize:16]];
    self.professorTextField.delegate = self;
    self.professorTextField.useKey = YES;
    [self.professorTextField.textField setClearsOnBeginEditing:YES];
    [self.professorTextField.textField setPlaceholder:@"Professor"];
    [self.view addSubview:self.professorTextField];
    
    self.scheduleTypePickerView = [[AKPickerView alloc] initWithFrame:CGRectMake(-10, self.scheduleTypeLabel.frame.origin.y + 10, 320, 64)];
    self.scheduleTypePickerView.delegate = self;
    PCCObject *myPreferredSearchTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    NSDictionary *subjectDictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySubject WithKey:myPreferredSearchTerm.value];
    self.scheduleTypes = [subjectDictionary objectForKey:kScheduleType];
    [self.view addSubview:self.scheduleTypePickerView];
    
    //create set to store days in
    self.setOfDays = [NSMutableSet setWithCapacity:5];
}

- (IBAction)dayPressed:(UIButton *)sender
{
    if ([self.setOfDays containsObject:sender]) {
        //in set..take out and animate back to normal
        [self.setOfDays removeObject:sender];
        [self pulseButton:sender];
        [UIView animateWithDuration:0.25f animations:^{
            [sender setBackgroundColor:[Helpers purdueColor:PurdueColorYellow]];
            [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }];
    }else {
        //not in set..add to set and animate as a day not counted
        [self.setOfDays addObject:sender];
        [self pulseButton:sender];
        [UIView animateWithDuration:0.25f animations:^{
            [sender setBackgroundColor:[UIColor whiteColor]];
            [sender setTitleColor:[Helpers purdueColor:PurdueColorYellow] forState:UIControlStateNormal];
        }];
    }
}

-(void)pulseButton:(UIButton *)button
{
    __block CGAffineTransform state;
    [UIView animateWithDuration:0.25f animations:^{
        state = button.transform;
        button.transform = CGAffineTransformScale(state, 1.25, 1.25);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f animations:^{
            button.transform = state;
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView
{
	return [self.scheduleTypes count];
}

- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item
{
    PCCObject *obj = self.scheduleTypes[item];
    return obj.key;
}

- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item
{
	PCCObject *obj = self.scheduleTypes[item];
    self.savedItem = obj;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark  - UITextFieldDelegate Methods

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{

}


@end
