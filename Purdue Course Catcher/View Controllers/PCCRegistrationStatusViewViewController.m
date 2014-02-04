//
//  PCCRegistrationStatusViewViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/27/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRegistrationStatusViewViewController.h"

#import "PCCRegistrationError.h"
#import "Helpers.h"

#define Y_OFFSET 220
@interface PCCRegistrationStatusViewViewController ()
{
    BOOL goRight;
    int lastPage;
}
@end

@implementation PCCRegistrationStatusViewViewController

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
    [self setupView];
    lastPage = -1;
	// Do any additional setup after loading the view.
}

-(void)setupView
{
    self.pageControl.numberOfPages = self.errorArray.count;
    [self.scrollView setContentSize:CGSizeMake(320*self.errorArray.count, self.scrollView.frame.size.height)];
    if (self.pageControl.numberOfPages > 1) {
        [self.scrollView setScrollEnabled:YES];
        self.registrationStatus.text = [self.registrationStatus.text stringByAppendingFormat:@"(%d/%d)", 1, self.errorArray.count];
    }
    //init first error
    PCCRegistrationError *error = [self.errorArray objectAtIndex:0];
    self.courseNumber.text = error.course;
    self.CRN.text = error.crn;
    self.registrationMessage.text = error.message;
    
    int offsetX = 320;
    for (int i = 1; i < self.errorArray.count; i++) {
        PCCRegistrationError *error = [self.errorArray objectAtIndex:i];
        
        UILabel *courseNumber = [[UILabel alloc] initWithFrame:CGRectMake(self.courseNumber.frame.origin.x+offsetX, self.courseNumber.frame.origin.y, self.courseNumber.frame.size.width, self.courseNumber.frame.size.height)];
        UILabel *registrationMessage = [[UILabel alloc] initWithFrame:CGRectMake(self.registrationMessage.frame.origin.x+offsetX, self.registrationMessage.frame.origin.y, self.registrationMessage.frame.size.width, self.registrationMessage.frame.size.height)];
        [registrationMessage setNumberOfLines:0];
        UILabel *crn = [[UILabel alloc] initWithFrame:CGRectMake(self.CRN.frame.origin.x+offsetX, self.CRN.frame.origin.y, self.CRN.frame.size.width, self.CRN.frame.size.height)];
        UILabel *registrationStatus = [[UILabel alloc] initWithFrame:CGRectMake(self.registrationStatus.frame.origin.x + offsetX, self.registrationStatus.frame.origin.y, self.registrationStatus.frame.size.width, self.registrationStatus.frame.size.height)];
        registrationStatus.text = [NSString stringWithFormat:@"Registration Status (%d/%d)", i+1, self.errorArray.count];
        courseNumber.text = error.course;
        registrationMessage.text = error.message;
        crn.text = error.crn;
        [registrationStatus setTextColor:self.registrationStatus.textColor];
        [courseNumber setTextColor:self.courseNumber.textColor];
        [registrationMessage setTextColor:self.registrationMessage.textColor];
        [crn setTextColor:self.CRN.textColor];
        [courseNumber setFont:self.courseNumber.font];
        [registrationMessage setFont:self.registrationMessage.font];
        [crn setFont:self.CRN.font];
        [registrationStatus setFont:self.registrationStatus.font];
        [registrationStatus setTextAlignment:self.registrationStatus.textAlignment];
        [self.scrollView addSubview:courseNumber];
        [self.scrollView addSubview:registrationMessage];
        [self.scrollView addSubview:crn];
        [self.scrollView addSubview:registrationStatus];
        offsetX += 320;
    }
    
    self.questionButton.transform = CGAffineTransformMakeTranslation(0, Y_OFFSET);
    self.answerLabel.transform = CGAffineTransformMakeTranslation(0, Y_OFFSET);
}

- (IBAction)dismissTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)questionTapped:(id)sender {
    [self refreshHelp];
    [self moveHelp];
}

-(void)moveHelp
{
    if (self.questionButton.tag == 1) {
        //if we are up
        
        [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.questionButton.transform = CGAffineTransformTranslate(self.questionButton.transform, 0, Y_OFFSET);
            self.answerLabel.transform = CGAffineTransformTranslate(self.answerLabel.transform, 0, Y_OFFSET);
        }completion:^(BOOL finished){
            if (finished ){
                self.questionButton.tag = 0;
            }
        }];
        
    }else {
        //if we are down
        [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.questionButton.transform = CGAffineTransformTranslate(self.questionButton.transform, 0, -Y_OFFSET);
            self.answerLabel.transform = CGAffineTransformTranslate(self.answerLabel.transform, 0, -Y_OFFSET);
        }completion:^(BOOL finished){
            if (finished ){
                self.questionButton.tag = 1;
            }
        }];

    }
}


-(NSString *)getClarificationForError:(NSString *)error
{
    if ([error rangeOfString:@"conflict"].location != NSNotFound) {
       return @"You have attempted to enroll in a class which has a time conflict with another of your classes. The system does not allow simultaneous enrollment in classes with overlapping meeting times (such as a Mon/Wed/Fri 1:00-1:50 class and a Mon 1:00-4:00 class) or double-booking (registering for two classes which meet at the same time).";
    }else if ([error rangeOfString:@"CORQ"].location != NSNotFound) {
        return @"This course has a co-requisite course that you have not yet registered for.";
    }else if ([error rangeOfString:@"Pre"].location != NSNotFound) {
        return @"This course has a pre-requisite that you have not yet completed.";
    }else if ([error rangeOfString:@"Closed"].location != NSNotFound) {
        return @"You have attempted to register for a course which is unavailable.";
    }else if ([error rangeOfString:@"available"].location != NSNotFound) {
        return @"You have attempted to register for a course which has restricted admittance to certain students.";
    }else if ([error rangeOfString:@"Duplicate"].location != NSNotFound) {
        return @"You have attempted to register for the same CRN twice.";
    }else if ([error rangeOfString:@"DUPL"].location != NSNotFound) {
        return @"You have attempted to register multiple sections of the same course.";
    }else if ([error rangeOfString:@"Maixmum"].location != NSNotFound) {
        return @"You have attempted to register for more hours than you are approved to take (usually 20 hours/semester).";
    }else if ([error rangeOfString:@"changes"].location != NSNotFound) {
        return @"You have attempted to add/drop a course that has a restricted add/drop window.";
    }else {
        return @"Unknown Error";
    }
}

#pragma mark ScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (lastPage == self.pageControl.currentPage) return;
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page < 0 || page >= self.pageControl.numberOfPages) return;
    lastPage = self.pageControl.currentPage;
    if (scrollView.contentOffset.x > 0) {
        goRight = YES;
    }else {
        goRight = NO;
    }
    self.pageControl.currentPage = page;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (lastPage == self.pageControl.currentPage) return;
    int translateX = 0;
    if (goRight) {
        translateX = 320;
    }else {
        translateX = -320;
    }
    [self performSelector:@selector(displayHelp:) withObject:[NSNumber numberWithInt:translateX] afterDelay:1.5f];
}

-(void)displayHelp:(NSNumber *)translateX
{
    int x_val = translateX.intValue;
    [self refreshHelp];
    self.questionButton.transform = CGAffineTransformTranslate(self.questionButton.transform, x_val, 50);
    self.answerLabel.transform = CGAffineTransformTranslate(self.answerLabel.transform, x_val, 50);
    
    [UIView animateWithDuration:0.25 delay:0.0 usingSpringWithDamping:0.7f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.questionButton.transform = CGAffineTransformTranslate(self.questionButton.transform, 0, -50);
        self.answerLabel.transform = CGAffineTransformTranslate(self.answerLabel.transform, 0, -50);
    }completion:nil];
}

-(void)refreshHelp
{
    PCCRegistrationError *error = self.errorArray[self.pageControl.currentPage];
    self.answerLabel.text = [self getClarificationForError:error.message];
    [self.answerLabel sizeToFit];
}
/*

 */

@end
