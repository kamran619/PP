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
#import "PCCAppDelegate.h"
#import "PCCSearchFilterViewController.h"


#define CENTER_FRAME CGPointMake(320, 21);

@interface PCCSearchViewController ()

@end

@implementation PCCSearchViewController
{
    
    PCCObject *myPreferredSearchTerm;
    NSArray *searchResults;
    PCCSearchFilterViewController *filterVC;
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
    [self.scrollView setContentOffset:CGPointZero animated:NO];
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
    if (!filterVC)  {
        filterVC = (PCCSearchFilterViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCSearchFilterViewController"];
        PCCObject *obj = [[PCCObject alloc] initWithKey:@"All" AndValue:@"%25"];
        filterVC.savedItem = obj;
    }
    
    //init animation controller
    self.animationController = [[ZoomAnimationController alloc] init];
    
    //setup subviews appearance
    
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.containerViewSearch.frame.size.height);

    //init autoCompleteViews
    CGPoint point = self.segmentedControl.center;
    CGRect frame = CGRectMake(10, point.y + 35, 300, 35);
    self.autoCompleteTextField = [[PCFAutoCompleteTextField alloc] initWithFrame:frame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
    //CGRect positionFrame = CGRectOffset(frame, 0, 70);
    //self.doneButton.frame = CGRectMake(positionFrame.origin.x, positionFrame.origin.y, self.doneButton.frame.size.width, self.doneButton.frame.size.height);
    [self.autoCompleteTextField setDataToAutoComplete:nil];
    
    [self.autoCompleteTextField.textField setFont:[UIFont systemFontOfSize:16]];
    [self.autoCompleteTextField.textField setClearsOnBeginEditing:YES];
    [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC 100"];
    self.autoCompleteTextField.useKey = NO;
    self.autoCompleteTextField.delegate = self;
    self.autoCompleteTextField.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self.containerViewSearch addSubview:self.autoCompleteTextField];
    
    //initialize selected segment
    self.segmentedControl.selectedSegmentIndex = 0;
    
    
    //setup scrollview
    if ([Helpers isPhone5]) {
        //self.advancedView.frame = CGRectOffset(self.advancedView.frame, 0, 40);
        //self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 75);
        //self.scheduleTypeTextField.frame = CGRectOffset(self.scheduleTypeTextField.frame, 0, 10);
        //self.scheduleTypeLabel.frame = CGRectOffset(self.scheduleTypeLabel.frame, 0, 10);
        //self.pageControl.frame = CGRectOffset(self.pageControl.frame, 0, 75);
        self.detailLabel.frame = CGRectOffset(self.detailLabel.frame, 0, 80);
    }
    
    //setup the views state
    PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredSearchTerm];
    if (term) self.termButton.title = term.key;
    
    //setup gestures
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [gesture setNumberOfTouchesRequired:1];
    [gesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [gesture setDelegate:self];
    [self.scrollView addGestureRecognizer:gesture];
    
    gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
    [gesture setNumberOfTouchesRequired:1];
    [gesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [gesture setDelegate:self];
    [self.scrollView addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setNumberOfTouchesRequired:1];
    [tapGesture setDelegate:self];
    [self.scrollView addGestureRecognizer:tapGesture];

}

-(void)swiped:(id)sender
{
    UISwipeGestureRecognizer *gesture = (UISwipeGestureRecognizer *)sender;
    int selected = (int) self.segmentedControl.selectedSegmentIndex;
    
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
            NSMutableArray *scheduleTypeArray = [overallArray objectAtIndex:2];
            NSMutableArray *professorArray = [overallArray objectAtIndex:1];
            [[PCCDataManager sharedInstance] setArrayProfessors:professorArray.mutableCopy];
            NSDictionary *subjectDict = @{kSubject: [overallArray objectAtIndex:0], kScheduleType : scheduleTypeArray};
            [[PCCDataManager sharedInstance] setObject:subjectDict ForKey:myPreferredSearchTerm.value InDictionary:DataDictionarySubject];
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
        vc.searchType = (int) self.segmentedControl.selectedSegmentIndex;
        vc.transitioningDelegate = self;
    }

}

#pragma mark - Touches

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}*/

-(void)tapped:(id)sender
{ 
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    CGPoint pointTapped = [gesture locationInView:gesture.view];
    CGPoint convertedPoint = [gesture.view convertPoint:pointTapped toView:self.autoCompleteTextField];
    CGRect textFieldRect = self.autoCompleteTextField.textField.frame;
    if (CGRectContainsPoint(textFieldRect, convertedPoint)) return;
    [self.view endEditing:YES];
}

#pragma mark Gesture Delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) return YES;
    return NO;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint touchLocation = [touch locationInView:gestureRecognizer.view];
    CGPoint convertedTouch = [self.autoCompleteTextField convertPoint:touchLocation fromView:self.scrollView];
    if (CGRectContainsPoint(self.autoCompleteTextField.tableView.frame, convertedTouch)) return NO;
    return YES;
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
    [self slideViewDown:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.autoCompleteTextField) {
        if (self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
            if (!self.autoCompleteTextField.dataToAutoComplete) {
                NSDictionary *subjectDictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySubject WithKey:myPreferredSearchTerm.value];
                [self.autoCompleteTextField setDataToAutoComplete:[subjectDictionary objectForKey:kSubject]];
            }else if (self.segmentedControl.selectedSegmentIndex == searchCRN) {
                [self.autoCompleteTextField setDataToAutoComplete:nil];
            }
        }
    }
    [self slideViewUp:textField];
}


#pragma mark UISegmentedControl Delegate
-(IBAction)valueChanged:(id)sender
{
    NSInteger val = [self.segmentedControl selectedSegmentIndex];
    [self.autoCompleteTextField.textField setText:@""];
    if (val == searchCourse) {
        [self.autoCompleteTextField setDataToAutoComplete:nil];
        [self hideFilterButton];
        //[self animateAdvancedViewOut];
        [self.fadeText setText:[self getTextForControl]];
        [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC 100"];
    }else if (val == searchCRN) {
        [self.autoCompleteTextField setDataToAutoComplete:nil];
        [self hideFilterButton];
        //[self animateAdvancedViewOut];
        [self.fadeText setText:[self getTextForControl]];
        [self.autoCompleteTextField.textField setPlaceholder:@"Example: A CRN is 5 digits"];
    }else if (val == searchAdvanced) {
        [self.fadeText setText:[self getTextForControl]];
        [self.autoCompleteTextField.textField setPlaceholder:@"Example: SOC"];
        [self showFilterButton];
        //[self animateAdvancedViewIn];
    }
}

-(void)showFilterButton
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_normal.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showFilters:)];
    [item setTintColor:[Helpers purdueColor:PurdueColorLightPink]];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

-(void)hideFilterButton
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

-(IBAction)showFilters:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    NSInteger state = button.tag;
    int toggleValue = (state == 0) ? 1 : 0;
    button.tag = toggleValue;
    if (toggleValue == 1) {
        [button setImage:[UIImage imageNamed:@"filter_selected.png"]];
    }else {
        [button setImage:[UIImage imageNamed:@"filter_normal.png"]];
    }
    [self toggleFilter:toggleValue];
}

-(void)toggleFilter:(int)toggle
{
    if (toggle == 0) {
        NSDictionary *subjectDictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySubject WithKey:myPreferredSearchTerm.value];
        filterVC.scheduleTypes = [subjectDictionary objectForKey:kScheduleType];
        NSArray *professorDataSource = [PCCDataManager sharedInstance].arrayProfessors;
        filterVC.professorTextField.dataToAutoComplete = professorDataSource.copy;
    }
    
    if (toggle == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            filterVC.view.alpha = 0.0f;
            filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
            CGPoint placement = CGPointZero;
            [self.view insertSubview:filterVC.view atIndex:0];
            [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.80f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                filterVC.view.frame = CGRectMake(placement.x, placement.y, filterVC.view.frame.size.width, filterVC.view.frame.size.height);
                filterVC.view.alpha = 1.0f;
                self.scrollView.layer.transform = CATransform3DMakeTranslation(0, filterVC.view.frame.size.height, 0);
            }completion:^(BOOL finished) {
                if (!finished) { filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
                }else {
                    filterVC.view.frame = CGRectMake(placement.x, placement.y, filterVC.view.frame.size.width, filterVC.view.frame.size.height);
                    filterVC.view.alpha = 1.0f;
                    self.scrollView.layer.transform = CATransform3DMakeTranslation(0, filterVC.view.frame.size.height, 0);
                }
            }];
        });
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            filterVC.view.alpha = 1.0f;
            [self.view addSubview:filterVC.view];
            [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.80f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                filterVC.view.alpha = 0.0f;
                filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
                self.scrollView.layer.transform = CATransform3DIdentity;
            }completion:^(BOOL finished) {
                if (finished) {
                    filterVC.view.alpha = 1.0f;
                    filterVC.view.frame = CGRectOffset(filterVC.view.frame, 0, -filterVC.view.frame.size.height);
                    //reload the table now with new data
                    self.isFiltered = YES;
                    [self refreshData];
                }
            }];
        });
    }
}

-(void)refreshData
{
    
}


#pragma mark Animations

-(void)fadeTextIn
{
    [self fadeText:[self getTextForControl] fromDirection:directionLeft];
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

-(void)showSearchResults
{
    /*UINavigationController *nc = [self.storyboard instantiateViewControllerWithIdentifier:@"PCCSearchResults"];
    PCCSearchResultsViewController *vc = [nc.childViewControllers lastObject];
    nc.transitioningDelegate = self;
    vc.dataSource = searchResults;
    vc.searchType = self.segmentedControl.selectedSegmentIndex;
    [self presentViewController:nc animated:YES completion:nil];*/
    [self performSegueWithIdentifier:@"SegueSearchResults" sender:nil];
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
            NSString *className = @"", *courseNumber = @"", *fromHours = @"", *toHours = @"", *professor = @"%25", *scheduleType = @"%25";
            
            if (filterVC.courseTitleTextField.text.length != 0) className = [filterVC.courseTitleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"%25"];
            if (filterVC.courseNumberTextField.text.length != 0) courseNumber = filterVC.courseNumberTextField.text;
            if (filterVC.professorTextField.textField.text.length != 0) professor = filterVC.professorTextField.selectedObject.value;
            if (![filterVC.savedItem.key isEqualToString:@"All"]) {
                scheduleType = filterVC.savedItem.value;
            }
            
            NSString *day=@"";
            if (filterVC.setOfDays.count != 0) {
                if (![filterVC.setOfDays containsObject:filterVC.mondayButton]){
                    day = [day stringByAppendingString:@"&sel_day=m"];
                }
                if (![filterVC.setOfDays containsObject:filterVC.tuesdayButton]){
                    day = [day stringByAppendingString:@"&sel_day=t"];
                }
                if (![filterVC.setOfDays containsObject:filterVC.wednesdayButton]){
                    day = [day stringByAppendingString:@"&sel_day=w"];
                }
                if (![filterVC.setOfDays containsObject:filterVC.thursdayButton]){
                    day = [day stringByAppendingString:@"&sel_day=r"];
                }
                if (![filterVC.setOfDays containsObject:filterVC.fridayButton]){
                    day = [day stringByAppendingString:@"&sel_day=f"];
                }
                if (![filterVC.setOfDays containsObject:filterVC.sundayButton]){
                    day = [day stringByAppendingString:@"&sel_day=u"];
                }
            }

            searchResults = [MyPurdueManager getCoursesWithParametersForTerm:myPreferredSearchTerm.value WithClassName:className AndCourseNumber:courseNumber AndSubject:self.autoCompleteTextField.textField.text FromHours:fromHours ToHours:toHours AndProfessor:professor AndDays:day scheduleType:scheduleType];
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
        
        //if (![self.scheduleTypeTextField.textField.text isEqualToString:@""]) {
        //    if ([self.scheduleTypeTextField.matchingData containsObject:self.scheduleTypeTextField.selectedObject]) {
        //        validation = YES;
        //    }
        //}
        if (!validation) {
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Incorrect Schedule Type" description:@"Pick a schedule type from the drop down box" type:TWMessageBarMessageTypeError];
            return NO;
        }
        return YES;
    }
    return NO;
}

-(void)slideViewUp:(UITextField *)textField
{
    int delta = 0;
    if ([Helpers isPhone5]) {
        if (textField == self.autoCompleteTextField && self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.fadeText.transform = CGAffineTransformMakeTranslation(0, 120);
                self.doneButton.transform = CGAffineTransformMakeTranslation(0, 120);
            }completion:^(BOOL finished) {
                
            }];
        }/*else if (textField == self.scheduleTypeTextField) {
            delta = 247;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 60);
                self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 50);
                self.pageControl.transform = CGAffineTransformMakeTranslation(0, 50);
                //self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
            }completion:^(BOOL finished) {
                
            }];
        }else if (textField == self.courseNumberTextField) {
            delta = 180;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                //self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 120);
                //self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.pageControl.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
            }completion:^(BOOL finished) {
                
            }];
        }else if (textField == self.courseTitleTextField) {
            delta = 165;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                //self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 120);
                //self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.pageControl.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
            }completion:^(BOOL finished) {
                
            }];
            
        }else if (textField == self.professorTextField) {
            delta = 160;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                //self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 70);
                //self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 66);
                //self.pageControl.transform = CGAffineTransformMakeTranslation(0, 66);
                
            }completion:^(BOOL finished) {
                
            }];
        }*/
    }else {
        if (textField == self.autoCompleteTextField && self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, 30) animated:YES];
                self.fadeText.transform = CGAffineTransformMakeTranslation(0, 120);
                self.doneButton.transform = CGAffineTransformMakeTranslation(0, 120);
            }completion:^(BOOL finished) {
                
            }];
        }/*else if (textField == self.scheduleTypeTextField) {
            delta = 247;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 120);
                self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 110);
                self.pageControl.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
            }completion:^(BOOL finished) {
                
            }];
        }else if (textField == self.courseNumberTextField) {
            delta = 180;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                //self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 120);
                //self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.pageControl.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
            }completion:^(BOOL finished) {
                
            }];
        }else if (textField == self.courseTitleTextField) {
            delta = 165;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                //self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 120);
                //self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.pageControl.transform = CGAffineTransformMakeTranslation(0, 110);
                //self.containerViewSearch.transform = CGAffineTransformMakeTranslation(0, -delta);
            }completion:^(BOOL finished) {
                
            }];

        }else if (textField == self.professorTextField) {
            delta = 190;
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, delta) animated:YES];
                self.advancedView.frame = CGRectMake(self.advancedView.frame.origin.x, self.advancedView.frame.origin.y, self.advancedView.frame.size.width, self.advancedView.frame.size.height + 120);
                self.detailLabel.transform = CGAffineTransformMakeTranslation(0, 110);
                self.pageControl.transform = CGAffineTransformMakeTranslation(0, 110);

            }completion:^(BOOL finished) {
                
            }];
        }*/
    }
}

-(void)slideViewDown:(UITextField *)textField
{
    if ([Helpers isPhone5]) {
        if (self.autoCompleteTextField == textField && self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.fadeText.transform = CGAffineTransformIdentity;
                self.doneButton.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                
            }];
        }
    }else {
        if (self.autoCompleteTextField == textField && self.segmentedControl.selectedSegmentIndex == searchAdvanced) {
            [UIView animateWithDuration:0.35f delay:0.0 usingSpringWithDamping:0.85f initialSpringVelocity:2.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                self.fadeText.transform = CGAffineTransformIdentity;
                self.doneButton.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                
            }];
        }
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
