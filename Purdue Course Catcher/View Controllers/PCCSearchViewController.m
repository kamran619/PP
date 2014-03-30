//
//  PCCSearchViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/16/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchViewController.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "PCCObject.h"
#import "PCCDataManager.h"
#import "PCFAutoCompleteTextField.h"
#import  "PCCSearchResultsViewController.h"
#import "ZoomAnimationController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Animations.h"
#import "TWMessageBarManager.h"
#import "PCCHUDManager.h"
#import "KPLightBoxManager.h"
#import "PCCTermViewController.h"


#define CENTER_FRAME CGPointMake(320, 21);



#define CUSTOM_PURPLE_COLOR [UIColor colorWithRed:.47843f green:0.4f blue:0.6f alpha:1]

#define BUTTON_CORNER_RADIUS 3.0f


@interface PCCSearchViewController ()

@end

@implementation PCCSearchViewController
{
    
    PCCObject *myPreferredSearchTerm;
    NSArray *searchResults;
    
    CATransition *animationTransition;
}

#pragma mark View Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initController];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fadeTextIn];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkIfSavedTerm];
    

}

-(void)checkIfSavedTerm
{
    //Check to see if the user has saved a preference for their search term
    PCCObject *preferredSearchTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    
    if (!preferredSearchTerm) {
        [self choosePreferredTerm:nil];
    }else {
        //we have the preferred search term saved..lets let them directly search
        myPreferredSearchTerm = [[PCCObject alloc] initWithKey:preferredSearchTerm.key AndValue:preferredSearchTerm.value];
        [self.termButton setTitle:myPreferredSearchTerm.key];
        [self.containerViewSearch fadeIn];
        //[self addBarButtonItem];
        //we have terms..lets show them, and still make a network call
        [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
            NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
            if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
        }];
    }
}
-(void)initController
{

    //[self.segmentedControl setTintColor:[Helpers purdueColor:PurdueColorYellow]];
    
    //init animation controller
    self.animationController = [[ZoomAnimationController alloc] init];
    
    //create set to store days in
    self.setOfDays = [NSMutableSet setWithCapacity:5];
    
    //setup subviews appearance
    self.advancedView.layer.cornerRadius = 9.0f;
    self.mondayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.tuesdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.wednesdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.thursdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.fridayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.sundayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.advancedView.hidden = YES;
    
    //init autoCompleteViews
    CGPoint point = self.segmentedControl.center;
    CGRect frame = CGRectMake(10, point.y + 35, 300, 35);
    self.autoCompleteTextField = [[PCFAutoCompleteTextField alloc] initWithFrame:frame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
    self.doneButton.frame = CGRectOffset(frame, 0, 70);
    [self.autoCompleteTextField setDataToAutoComplete:nil];
    [self.autoCompleteTextField.textField setFont:[UIFont systemFontOfSize:16]];
    [self.autoCompleteTextField.textField setClearsOnBeginEditing:YES];
    [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC 100"];
    self.autoCompleteTextField.useKey = NO;
    self.autoCompleteTextField.delegate = self;
    self.autoCompleteTextField.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self.containerViewSearch addSubview:self.autoCompleteTextField];
    
    //setup professor autocomplete //15 28 257
    frame = CGRectMake(15, 28, 257, 35);
    self.professorTextField = [[PCFAutoCompleteTextField alloc] initWithFrame:frame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
    self.professorTextField.dataToAutoComplete = nil;
    [self.professorTextField.textField setFont:[UIFont systemFontOfSize:16]];
    self.professorTextField.delegate = self;
    self.professorTextField.useKey = YES;
    [self.professorTextField.textField setClearsOnBeginEditing:YES];
    [self.professorTextField.textField setPlaceholder:@"Professor"];
    [self.advancedView addSubview:self.professorTextField];
    
    //initialize selected segment
    self.segmentedControl.selectedSegmentIndex = 0;
    
    //setup the views state
    PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    if (term) self.termButton.title = term.key;
    
    //setup gestures
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [gesture setNumberOfTouchesRequired:1];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:gesture];
    
    gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [gesture setNumberOfTouchesRequired:1];
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:gesture];

}

-(void)swiped:(id)sender
{
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;
    int selected = self.segmentedControl.selectedSegmentIndex;
    
    switch (gesture.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            if (selected > 0) {
                selected--;
                self.segmentedControl.selectedSegmentIndex = selected;
                [self valueChanged:nil];
            }
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            if (selected < 2) {
                selected++;
                self.segmentedControl.selectedSegmentIndex = selected;
                [self valueChanged:nil];
            }
            break;
        default:
            break;
    }
}

#pragma mark PCCTerm Delegate
-(void)termPressed:(PCCObject *)term
{
    myPreferredSearchTerm = [[PCCObject alloc] initWithKey:term.key AndValue:term.value];
    self.termButton.title = myPreferredSearchTerm.key;
    [[PCCDataManager sharedInstance] setObject:myPreferredSearchTerm ForKey:kPreferredSearchTerm InDictionary:DataDictionaryUser];
    
    [self.containerViewSearch fadeIn];
    
    NSArray *subjectArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySubject WithKey:kPreferredSearchTerm];
    if (!subjectArray) {
        [Helpers asyncronousBlockWithName:@"Get Subjects for Term" AndBlock:^{
            NSArray *overallArray = [MyPurdueManager getSubjectsAndProfessorsForTerm:myPreferredSearchTerm.value];
            [[PCCDataManager sharedInstance] setObject:[overallArray objectAtIndex:0] ForKey:myPreferredSearchTerm.value InDictionary:DataDictionarySubject];
            NSMutableArray *professorArray = [overallArray objectAtIndex:1];
            [[PCCDataManager sharedInstance] setArrayProfessors:professorArray.mutableCopy];
        }];
    }
}

#pragma mark Buttons
- (IBAction)choosePreferredTerm:(id)sender
{
    [self performSegueWithIdentifier:@"SegueSemester" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueSemester"]) {
        UINavigationController *controller = segue.destinationViewController;
            PCCTermViewController *termVC = (PCCTermViewController *)controller.childViewControllers.lastObject;
            [termVC setType:PCCTermTypeSearch];
            [termVC setDataSource:[PCCDataManager sharedInstance].arrayTerms];
            termVC.delgate = self;
    }else if ([segue.identifier isEqualToString:@"SegueSearchResults"]) {
        UINavigationController *controller = segue.destinationViewController;
        PCCSearchResultsViewController *vc = [controller.childViewControllers lastObject];
        vc.dataSource = searchResults;
        vc.searchType = self.segmentedControl.selectedSegmentIndex;
        vc.transitioningDelegate = self;
    }

}

#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

#pragma mark - Utility Methods

-(void)fadeText:(NSString *)str fromDirection:(direction)direction
{
    //self.fadeText.alpha = 0.0f;
    self.fadeText.text = str;
    self.fadeText.transform = CGAffineTransformMakeTranslation(-40, 0);
    [UIView animateWithDuration:0.8f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.fadeText.transform = CGAffineTransformTranslate(self.fadeText.transform, 40, 0);
        //self.fadeText.alpha = 1.0f;
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark  - UITextFieldDelegate Methods

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.courseNumberTextField || textField == self.courseTitleTextField || textField == self.professorTextField)
    {
            [self slideViewDown];
    }

    [self pulseButton:self.doneButton];
}

#pragma mark UISegmentedControl Delegate
-(IBAction)valueChanged:(id)sender
{
    NSInteger val = [self.segmentedControl selectedSegmentIndex];
    [self.autoCompleteTextField.textField setText:@""];
    if (val == searchCourse) {
        [self.autoCompleteTextField setDataToAutoComplete:nil];
        [self animateAdvancedViewOut];
        [self.fadeText setText:[self getTextForControl]];
        [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC 100"];
    }else if (val == searchCRN) {
        [self.autoCompleteTextField setDataToAutoComplete:nil];
        [self animateAdvancedViewOut];
        [self.fadeText setText:[self getTextForControl]];
        [self.autoCompleteTextField.textField setPlaceholder:@"Example: A CRN is 5 digits"];
    }else if (val == searchAdvanced) {
        [self.fadeText setText:[self getTextForControl]];
        [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC"];
        [self animateAdvancedViewIn];
    }
}

#pragma mark Animations

-(void)fadeTextIn
{
    [self fadeText:[self getTextForControl] fromDirection:directionLeft];
}
#define ANIMATION_DURATION 0.4f
-(void)animateAdvancedViewIn
{
    if (!self.advancedView.hidden) return;
    [self moveDoneButton:directionDown WithBlock:^{
        self.advancedView.transform = CGAffineTransformMakeTranslation(-300, 0);
        self.advancedView.hidden = NO;
        [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.advancedView.transform = CGAffineTransformIdentity;
        }completion:nil];
        /*[UIView animateKeyframesWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
            //move and rotate view to right wall
            [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.3f animations:^{
                CGAffineTransform translate = CGAffineTransformTranslate(self.advancedView.transform ,self.view.frame.size.width + 10, 0);
                self.advancedView.transform = translate;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.3f relativeDuration:.10 animations:^{
                state = self.advancedView.transform;
                CGAffineTransform rotate = CGAffineTransformRotate(self.advancedView.transform, RADIANS(-10));
                self.advancedView.transform = CGAffineTransformTranslate(rotate, -25, 0);
            }];
            [UIView addKeyframeWithRelativeStartTime:0.4f relativeDuration:.4f animations:^{
                self.advancedView.transform = CGAffineTransformIdentity;
            }];
         
            
        }completion:^(BOOL finished) {
            //if (finished) [self performSelector:@selector(pulseButton) withObject:nil afterDelay:0.15];
        }];*/
    }];
}
-(void)animateAdvancedViewOut
{
    if (self.advancedView.hidden) return;
    /*[UIView animateKeyframesWithDuration:ANIMATION_DURATION/2 delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:.20f animations:^{
            self.advancedView.transform = CGAffineTransformMakeTranslation(30, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:.20f relativeDuration:.20f animations:^{
            self.advancedView.transform = CGAffineTransformTranslate(self.advancedView.transform, -self.view.frame.size.width, 0);
        }];
    }completion:^(BOOL finished) {

    }];*/
    [UIView animateWithDuration:ANIMATION_DURATION delay:0.0f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.advancedView.transform = CGAffineTransformMakeTranslation(-300, 0);
    }completion:^(BOOL finished) {
        if (finished) {
            self.advancedView.hidden = YES;
            self.advancedView.transform = CGAffineTransformIdentity;
            [self moveDoneButton:directionUp WithBlock:nil];
        }
    }];
}

-(NSString *)getTextForControl
{
    switch (self.segmentedControl.selectedSegmentIndex) {
            
        case searchCourse:
            return @"Provide a department and course number";
            break;
        case searchCRN:
            return @"Provide a 5 digit CRN";
            break;
        case searchAdvanced:
            return @"Provide a department";
            break;
        default:
            return nil;
            break;
    }
}

- (IBAction)dayPressed:(UIButton *)sender
{
    if ([self.setOfDays containsObject:sender]) {
        //in set..take out and animate back to normal
        [self.setOfDays removeObject:sender];
        [self pulseButton:sender];
        [UIView animateWithDuration:0.25f animations:^{
            [sender setBackgroundColor:CUSTOM_PURPLE_COLOR];
        }];
    }else {
        //not in set..add to set and animate as a day not counted
        [self.setOfDays addObject:sender];
        [self pulseButton:sender];
        [UIView animateWithDuration:0.25f animations:^{
            [sender setBackgroundColor:[UIColor lightGrayColor]];
        }];
    }
}



-(void)showSearchResults
{
    /*UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PCCSearchResults"];
    PCCSearchResultsViewController *vc = [nc.childViewControllers lastObject];
    nc.transitioningDelegate = self;
    vc.dataSource = searchResults;
    vc.searchType = self.segmentedControl.selectedSegmentIndex;
    [self presentViewController:nc animated:YES completion:nil];*/
    [self performSegueWithIdentifier:@"SegueSearchResulst" sender:nil];
}
- (IBAction)searchPressed:(id)sender {
    
    if ([self validateInput] == NO) return;

    if (self.segmentedControl.selectedSegmentIndex == searchCourse) {
        
        NSArray *splitTerms = [self.autoCompleteTextField.textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
        [Helpers asyncronousBlockWithName:@"Get Courses" AndBlock:^{
            
            searchResults = [MyPurdueManager getCoursesForTerm:myPreferredSearchTerm.value WithClassName:[splitTerms objectAtIndex:0] AndCourseNumber:[splitTerms objectAtIndex:1]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
                [[PCCHUDManager sharedInstance] dismissHUD];
                [self showSearchResults];
            });;
            
        }];
    }else if (self.segmentedControl.selectedSegmentIndex == searchCRN) {
        [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
        [Helpers asyncronousBlockWithName:@"Get Courses" AndBlock:^{
            searchResults = [MyPurdueManager getCoursesForTerm:myPreferredSearchTerm.value WithCRN:self.autoCompleteTextField.textField.text];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PCCHUDManager sharedInstance] dismissHUD];
                [self showSearchResults];
                //[self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
            });
            
        }];
    }else if (self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
        [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
        [Helpers asyncronousBlockWithName:@"Get Courses" AndBlock:^{
            NSString *className = @"", *courseNumber = @"", *fromHours = @"", *toHours = @"", *professor = @"%25";
            
            if (self.courseTitleTextField.text.length != 0) className = [self.courseTitleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%25"];
            if (self.courseNumberTextField.text.length != 0) courseNumber = self.courseNumberTextField.text;
            if (self.professorTextField.textField.text.length != 0) professor = self.professorTextField.selectedObject.value;
            
            NSString *day=@"";
            if (self.setOfDays.count != 0) {
                if (![self.setOfDays containsObject:self.mondayButton]){
                    day = [day stringByAppendingString:@"&sel_day=m"];
                }
                if (![self.setOfDays containsObject:self.tuesdayButton]){
                    day = [day stringByAppendingString:@"&sel_day=t"];
                }
                if (![self.setOfDays containsObject:self.wednesdayButton]){
                    day = [day stringByAppendingString:@"&sel_day=w"];
                }
                if (![self.setOfDays containsObject:self.thursdayButton]){
                    day = [day stringByAppendingString:@"&sel_day=r"];
                }
                if (![self.setOfDays containsObject:self.fridayButton]){
                    day = [day stringByAppendingString:@"&sel_day=f"];
                }
                if (![self.setOfDays containsObject:self.sundayButton]){
                    day = [day stringByAppendingString:@"&sel_day=u"];
                }
            }

            searchResults = [MyPurdueManager getCoursesWithParametersForTerm:myPreferredSearchTerm.value WithClassName:className AndCourseNumber:courseNumber AndSubject:self.autoCompleteTextField.textField.text FromHours:fromHours ToHours:toHours AndProfessor:professor AndDays:day];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[PCCHUDManager sharedInstance] dismissHUD];
                [self showSearchResults];
                //[self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
            });
            
        }];
    }
}

-(BOOL)validateInput
{
    BOOL validation = YES;
    
    if (self.segmentedControl.selectedSegmentIndex == searchCourse) {
        NSArray *splitTerms = [self.autoCompleteTextField.textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (splitTerms.count != 2) {
            validation = NO;
            if (!validation) {
                [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Incorrect Format" description:@"Ex: SOC 100" type:TWMessageBarMessageTypeError];
                return validation;
            }
        }
        NSCharacterSet *alphaSet = [NSCharacterSet letterCharacterSet];
        NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
        if ([[splitTerms objectAtIndex:0] rangeOfCharacterFromSet:alphaSet].location == NSNotFound) validation = NO;
        if ([[splitTerms objectAtIndex:1] rangeOfCharacterFromSet:numberSet].location == NSNotFound) validation = NO;
        if (!validation) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Incorrect Format" description:@"Ex: SOC 100" type:TWMessageBarMessageTypeError];
            return validation;
        }
        return validation;
    }else if (self.segmentedControl.selectedSegmentIndex == searchCRN) {
        NSCharacterSet *characterSet = [NSCharacterSet decimalDigitCharacterSet];
        if ([self.autoCompleteTextField.textField.text rangeOfCharacterFromSet:characterSet].location == NSNotFound) validation =NO;
        if (!validation) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Incorrect Format" description:@"Ex: 12345" type:TWMessageBarMessageTypeError];
            return NO;
        }
        return YES;
    }else if (self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
        validation = NO;
        if ([self.autoCompleteTextField.matchingData containsObject:self.autoCompleteTextField.selectedObject]) {
            validation = YES;
        }
        if (!validation) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Incorrect Subject" description:@"Pick a subject from the drop down box" type:TWMessageBarMessageTypeError];
            return NO;
        }
        return YES;
    }
    return NO;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [Helpers asyncronousBlockWithName:@"Textfield begin editing" AndBlock:^{
        if (textField == self.courseNumberTextField) {
            [self slideViewUp:45];
        }else if (textField == self.professorTextField) {
            if (!self.professorTextField.dataToAutoComplete) {
                NSArray *professorDataSource = [PCCDataManager sharedInstance].arrayProfessors;
                [self.professorTextField setDataToAutoComplete:professorDataSource.copy];
            }
            [self slideViewUp:45];
        }else if (textField == self.courseTitleTextField) {
            [self slideViewUp:10];
        }else if (textField == self.autoCompleteTextField) {
            if (self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
                if (!self.autoCompleteTextField.dataToAutoComplete) {
                    NSArray *dataSource = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySubject WithKey:myPreferredSearchTerm.value];
                    [self.autoCompleteTextField setDataToAutoComplete:dataSource.copy];
                }
            }
        }
 
    }];
}

-(void)slideViewUp:(int)delta
{
    [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
    }completion:^(BOOL finished) {
        
    }];
    
}

-(void)slideViewDown
{
    [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.containerViewSearch.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        
    }];

    
}

-(void)moveDoneButton:(direction)dir WithBlock:(void(^)())block
{
    if (dir == directionUp) {
        [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.doneButton.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            if (finished) if (block) block();
        }];
    }else if (dir == directionDown) {
        [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.doneButton.transform = CGAffineTransformMakeTranslation(0, self.advancedView.frame.size.height + 35);
        }completion:^(BOOL finished) {
            if (finished) if (block) block();
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

#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    myPreferredSearchTerm = obj;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    
    return obj.key;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}
#pragma mark UIPickerView Data Source
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[PCCDataManager sharedInstance] arrayTerms] count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

@end
