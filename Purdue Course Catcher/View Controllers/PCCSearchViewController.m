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
#import "MHNatGeoViewControllerTransition.h"
#import "ZoomAnimationController.h"
#import <QuartzCore/QuartzCore.h>

#define CENTER_FRAME CGPointMake(320, 21);
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
#define CUSTOM_PURPLE_COLOR [UIColor colorWithRed:.47843f green:0.4f blue:0.6f alpha:1]
@interface PCCSearchViewController ()

@end

enum search
{
    searchCourse = 0,
    searchCRN = 1,
    searchAdvanced = 2
} typedef search;

@implementation PCCSearchViewController
{
    NSString *myPreferredSearchTerm;
    CATransition *animationTransition;
    UITextField *currentTextField;
    NSArray *searchResults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.animationController = [[ZoomAnimationController alloc] init];
    
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255 green:17 blue:0 alpha:0.7f]];
    self.setOfDays = [NSMutableSet setWithCapacity:5];
    [self setupSearchView];
    [self addTapRecognizer];
    [self setupView];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setBarTintColorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
    UIColor *tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    self.navigationController.navigationBar.barTintColor = tintColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fadeTextIn];
}

-(void)addTapRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [tap setCancelsTouchesInView:NO];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
}

-(void)tapped:(id)sender
{
    [self.autoCompleteTextField.textField resignFirstResponder];
    [self.professorTextField.textField resignFirstResponder];
    [self.courseNumberTextField resignFirstResponder];
    [self.courseTitleTextField resignFirstResponder];
}

- (void)setupView
{
    NSString *preferredSearchTerm = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    if (!preferredSearchTerm) {
        if (![PCCDataManager sharedInstance].arrayTerms) {
            //terms have never been aggregated
            [self.containerView setHidden:YES];
            [self.containerViewSearch setHidden:YES];
            [self.activityIndicator startAnimating];
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                [[PCCDataManager sharedInstance] setArrayTerms:[MyPurdueManager getMinimalTerms].mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self.containerView setHidden:NO];
                    [self.pickerView reloadAllComponents];
                    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
                    myPreferredSearchTerm = obj.value;
                });
            }];
        }else {
            [self.containerView setHidden:NO];
            [self.containerViewSearch setHidden:YES];
            [self.pickerView reloadAllComponents];
            //we have terms..lets show them, and still make a network call
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
                if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pickerView reloadAllComponents];
                    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
                    myPreferredSearchTerm = obj.value;
                });
            }];

        }
    }else {
        //we have the preferred search term saved..lets let them directly search
        myPreferredSearchTerm = preferredSearchTerm;
        self.containerView.center = CENTER_FRAME;
        self.containerView.hidden = YES;
        self.containerViewSearch.hidden = NO;
        [self addBarButtonItem];
        //we have terms..lets show them, and still make a network call
        [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
            NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
            if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickerView reloadAllComponents];
            });
        }];
    }
}

#define BUTTON_CORNER_RADIUS 3.0f
-(void)setupSearchView
{
    self.advancedView.layer.cornerRadius = 9.0f;
    self.mondayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.tuesdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.wednesdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.thursdayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.fridayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.sundayButton.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.advancedView.hidden = YES;
    [self initAutoCompleteTextView];
}



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

-(void)initAutoCompleteTextView
{
    CGPoint point = self.segmentedControl.center;
    CGRect frame = CGRectMake(40, point.y + 45, 240, 35);
    self.autoCompleteTextField = [[PCFAutoCompleteTextField alloc] initWithFrame:frame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
    [self.autoCompleteTextField setDataToAutoComplete:nil];
    [self.autoCompleteTextField.textField setFont:[UIFont systemFontOfSize:16]];
    [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC 100"];
    self.autoCompleteTextField.useKey = NO;
    self.autoCompleteTextField.delegate = self;
    [self.containerViewSearch addSubview:self.autoCompleteTextField];

    //setup professor autocomplete //15 28 257
    frame = CGRectMake(15, 28, 257, 35);
    self.professorTextField = [[PCFAutoCompleteTextField alloc] initWithFrame:frame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
    self.professorTextField.dataToAutoComplete = nil;
    [self.professorTextField.textField setFont:[UIFont systemFontOfSize:16]];
    self.professorTextField.delegate = self;
    self.professorTextField.useKey = YES;
    [self.professorTextField.textField setPlaceholder:@"Professor"];
    [self.advancedView addSubview:self.professorTextField];
    self.segmentedControl.selectedSegmentIndex = 0;
    //[self valueChanged:nil];
}
-(void)addBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(choosePreferredTerm:)];
    [self.navItem setRightBarButtonItem:item animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.courseNumberTextField || textField == self.courseTitleTextField || textField == self.professorTextField)
    {
            [self slideViewDown];
    }

    
    //currentTextField = nil;
    PCFAutoCompleteTextField *atf = (PCFAutoCompleteTextField *)textField;
    [self pulseButton:self.doneButton];
    [self performSelector:@selector(pulseButton:) withObject:self.doneButton afterDelay:.51];
}
- (IBAction)choosePreferredTerm:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        self.containerViewSearch.transform = CGAffineTransformMakeScale(1, .001);
    }completion:^(BOOL finished) {
        self.containerViewSearch.hidden = YES;
        self.containerViewSearch.transform = CGAffineTransformIdentity;
        [self.containerView setHidden:NO];
        self.containerView.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [UIView animateWithDuration:0.5f animations:^{
            self.containerView.center = self.containerViewSearch.center;
            self.containerView.transform = CGAffineTransformMakeScale(1, 1);
            [self.navItem setRightBarButtonItem:nil animated:YES];
        }];
    }];
}

- (IBAction)proceedToSearch:(id)sender
{
    [[PCCDataManager sharedInstance] setObject:myPreferredSearchTerm ForKey:kPreferredSearchTerm InDictionary:DataDictionaryUser];
    NSArray *subjectArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySubject WithKey:kPreferredSearchTerm];
    if (!subjectArray) {
        [Helpers asyncronousBlockWithName:@"Get Subjects for Term" AndBlock:^{
            NSArray *overallArray = [MyPurdueManager getSubjectsAndProfessorsForTerm:myPreferredSearchTerm];
            [[PCCDataManager sharedInstance] setObject:[overallArray objectAtIndex:0] ForKey:myPreferredSearchTerm InDictionary:DataDictionarySubject];
            NSMutableArray *professorArray = [overallArray objectAtIndex:1];
            [[PCCDataManager sharedInstance] setArrayProfessors:professorArray.mutableCopy];
        }];
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.containerView.center = CENTER_FRAME;
            self.containerView.transform = CGAffineTransformMakeScale(.001, .001);
    }completion:^(BOOL finished) {
        self.containerView.transform = CGAffineTransformIdentity;
        self.containerView.hidden = YES;
        self.containerViewSearch.hidden = NO;
        self.containerViewSearch.transform = CGAffineTransformMakeScale(1, .001);
        [self addBarButtonItem];
        [UIView animateWithDuration:0.5f animations:^{
            self.containerViewSearch.transform = CGAffineTransformMakeScale(1, 1);
        }];
    }];
}

#pragma mark UISegmentedControl Delegate
-(IBAction)valueChanged:(id)sender
{
    NSInteger val = [self.segmentedControl selectedSegmentIndex];
    
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
        NSArray *dataSource = [[PCCDataManager sharedInstance].dictionarySubjects objectForKey:myPreferredSearchTerm];
        NSArray *professorDataSource = [PCCDataManager sharedInstance].arrayProfessors;
        [self.autoCompleteTextField setDataToAutoComplete:dataSource.copy];
        [self.professorTextField setDataToAutoComplete:professorDataSource.copy];
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
#define ANIMATION_DURATION 0.8f
-(void)animateAdvancedViewIn
{
    if (!self.advancedView.hidden) return;
    [self moveDoneButton:directionDown WithBlock:^{
        self.advancedView.transform = CGAffineTransformMakeTranslation(-300, 0);
        self.advancedView.hidden = NO;
        __block CGAffineTransform state;
        [UIView animateKeyframesWithDuration:ANIMATION_DURATION delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
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
        }];
    }];
}
-(void)animateAdvancedViewOut
{
    if (self.advancedView.hidden) return;
    [UIView animateKeyframesWithDuration:ANIMATION_DURATION/2 delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:.20f animations:^{
            self.advancedView.transform = CGAffineTransformMakeTranslation(30, 0);
        }];
        [UIView addKeyframeWithRelativeStartTime:.20f relativeDuration:.20f animations:^{
            self.advancedView.transform = CGAffineTransformTranslate(self.advancedView.transform, -self.view.frame.size.width, 0);
        }];
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
            return @"Begin by specifying the department and course number.";
            break;
        case searchCRN:
            return @"Begin by specifying the CRN for a course you want to search for.";
            break;
        case searchAdvanced:
            return @"Begin by entering the department the course you want to search for is in.";
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchResultsSegue"]) {
        UINavigationController *controller = segue.destinationViewController;
        PCCSearchResultsViewController *vc = [controller.childViewControllers lastObject];
        vc.transitioningDelegate = self;
        [vc setDataSource:searchResults];
    }
}

-(void)showSearchResults
{
    UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PCCSearchResults"];
    PCCSearchResultsViewController *vc = [nc.childViewControllers lastObject];
    nc.transitioningDelegate = self;
    vc.dataSource = searchResults;
    [self presentViewController:nc animated:YES completion:nil];
}
- (IBAction)searchPressed:(id)sender {
    
    if ([self validateInput] == NO) return;

    if (self.segmentedControl.selectedSegmentIndex == searchCourse) {
        NSArray *splitTerms = [self.autoCompleteTextField.textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [Helpers asyncronousBlockWithName:@"Get Courses" AndBlock:^{
            searchResults = [MyPurdueManager getCoursesForTerm:myPreferredSearchTerm WithClassName:[splitTerms objectAtIndex:0] AndCourseNumber:[splitTerms objectAtIndex:1]];
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
                [self showSearchResults];
            });;
            
        }];
    }else if (self.segmentedControl.selectedSegmentIndex == searchCRN) {
        [Helpers asyncronousBlockWithName:@"Get Courses" AndBlock:^{
            searchResults = [MyPurdueManager getCoursesForTerm:myPreferredSearchTerm WithCRN:self.autoCompleteTextField.textField.text];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSearchResults];
                //[self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
            });
            
        }];
    }else if (self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
        [Helpers asyncronousBlockWithName:@"Get Courses" AndBlock:^{
            NSString *className = @"", *courseNumber = @"", *fromHours = @"", *toHours = @"", *professor = @"%25";
            
            if (self.courseTitleTextField.text.length != 0) className = [self.courseTitleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%25"];
            if (self.courseNumberTextField.text.length != 0) courseNumber = self.courseNumberTextField.text;
            if (self.professorTextField.textField.text.length != 0) professor = self.professorTextField.selectedObject.value;
            
            NSString *day = @"";
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

            searchResults = [MyPurdueManager getCoursesWithParametersForTerm:myPreferredSearchTerm WithClassName:className AndCourseNumber:courseNumber AndSubject:self.autoCompleteTextField.textField.text FromHours:fromHours ToHours:toHours AndProfessor:professor AndDays:day];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSearchResults];
                //[self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
            });
            
        }];
    }
}

-(BOOL)validateInput
{
    if (self.segmentedControl.selectedSegmentIndex == searchCourse) {
        NSArray *splitTerms = [self.autoCompleteTextField.textField.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (splitTerms.count != 2) return NO;
        NSCharacterSet *alphaSet = [NSCharacterSet letterCharacterSet];
        NSCharacterSet *numberSet = [NSCharacterSet decimalDigitCharacterSet];
        if ([[splitTerms objectAtIndex:0] rangeOfCharacterFromSet:alphaSet].location == NSNotFound) return NO;
        if ([[splitTerms objectAtIndex:1] rangeOfCharacterFromSet:numberSet].location == NSNotFound) return NO;
        return YES;
    }else if (self.segmentedControl.selectedSegmentIndex == searchCRN) {
        NSCharacterSet *characterSet = [NSCharacterSet decimalDigitCharacterSet];
        if ([self.autoCompleteTextField.textField.text rangeOfCharacterFromSet:characterSet].location == NSNotFound) return NO;
        return YES;
    }else if (self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
        if ([self.autoCompleteTextField.matchingData containsObject:self.autoCompleteTextField.selectedObject]) {
            return YES;
        }
    }
    
    return NO;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isKindOfClass:[PCFAutoCompleteTextField class]]) {
        PCFAutoCompleteTextField *atf = (PCFAutoCompleteTextField *)textField;
        [atf.textField resignFirstResponder];
        return YES;
    }
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.courseNumberTextField) {
        [self slideViewUp:45];
    }else if (textField == self.professorTextField) {
        [self slideViewUp:45];
    }else if (textField == self.courseTitleTextField) {
        [self slideViewUp:10];
    }
    currentTextField = textField;
}

-(void)slideViewUp:(int)delta
{
    /*[UIView animateWithDuration:0.25f animations:^{
        self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -50);
    }];*/
    
    [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
    }completion:^(BOOL finished) {
        
    }];
    
}

-(void)slideViewDown
{
   /* [UIView animateWithDuration:0.25f animations:^{
        self.containerViewSearch.transform = CGAffineTransformIdentity;
    }];*/
    [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.containerViewSearch.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        
    }];

    
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([currentTextField isKindOfClass:[PCFAutoCompleteTextField class]]) {
        PCFAutoCompleteTextField *textField = (PCFAutoCompleteTextField *)currentTextField;
        if (!textField) {
            return NO;
        }else if (textField.displayingAutoSuggest == YES) {
            return NO;
        }
        return YES;
    }else {
        return YES;
    }
}
-(void)moveDoneButton:(direction)dir WithBlock:(void(^)())block
{
    if (dir == directionUp) {
        [UIView animateWithDuration:0.75f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.doneButton.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            if (finished) if (block) block();
        }];
    }else if (dir == directionDown) {
        [UIView animateWithDuration:0.75f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.doneButton.transform = CGAffineTransformMakeTranslation(0, self.advancedView.frame.size.height + 10);
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
        if (finished) {
            [UIView animateWithDuration:0.25f animations:^{
                button.transform = state;
            }];
        }
    }];
}

#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    myPreferredSearchTerm = obj.value;
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
