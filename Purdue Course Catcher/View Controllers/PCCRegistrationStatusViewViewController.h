//
//  PCCRegistrationStatusViewViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/27/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCRegistrationStatusViewViewController : UIViewController <UIScrollViewDelegate>

- (IBAction)dismissTapped:(id)sender;


@property (nonatomic, strong) NSArray *errorArray;


@property (nonatomic, strong) IBOutlet UILabel *registrationStatus;
@property (nonatomic, strong) IBOutlet UILabel *registrationMessage;
@property (nonatomic, strong) IBOutlet UILabel *courseNumber;
@property (nonatomic, strong) IBOutlet UILabel *CRN;
@property (nonatomic, strong) IBOutlet UIButton *questionButton;
@property (nonatomic, strong) IBOutlet UILabel *answerLabel;
@property (nonatomic, strong) IBOutlet UIButton *dismissButton;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@end
