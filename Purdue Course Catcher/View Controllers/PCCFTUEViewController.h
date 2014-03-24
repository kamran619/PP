//
//  PCCFTUEViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADVAnimationController.h"
#import "PCFNetworkManager.h"

@interface PCCFTUEViewController : UIViewController <UIScrollViewDelegate, UIViewControllerTransitioningDelegate, PCFNetworkDelegate>

-(void)dismissMe;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UILabel *mainTitle;
@property (nonatomic, strong) IBOutlet UILabel *mainBody;
@property (nonatomic, strong) IBOutlet UILabel *subBody;

@property (nonatomic, strong) IBOutlet UILabel *bigB;
@property (nonatomic, strong) IBOutlet UILabel *bigBTwo;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;
@property (nonatomic, strong) IBOutlet UILabel *thirdLabel;

@property (nonatomic, strong) IBOutlet UIImageView *bubbles;

@property (nonatomic, strong) IBOutlet UIButton *facebookButton;
@property (nonatomic, strong) IBOutlet UIButton *purdueButton;
@property (nonatomic, strong) IBOutlet UIButton *skipButton;

@property (nonatomic, strong) IBOutlet UILabel *socialLabel;
@property (nonatomic, strong) IBOutlet UILabel *socialText;

@property (nonatomic, assign) int fbLaunched;

@property (nonatomic, strong) id <ADVAnimationController> animationController;

@end
