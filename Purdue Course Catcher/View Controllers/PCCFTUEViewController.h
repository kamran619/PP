//
//  PCCFTUEViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADVAnimationController.h"

@interface PCCFTUEViewController : UIViewController <UIScrollViewDelegate, UIViewControllerTransitioningDelegate>

-(void)dismissMe;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) IBOutlet UILabel *mainTitle;
@property (nonatomic, strong) IBOutlet UILabel *mainBody;
@property (nonatomic, strong) IBOutlet UILabel *subBody;

@property (nonatomic, strong) IBOutlet UILabel *bigP;
@property (nonatomic, strong) IBOutlet UILabel *bigC;
@property (nonatomic, strong) IBOutlet UILabel *bigCTwo;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;
@property (nonatomic, strong) IBOutlet UILabel *thirdLabel;

@property (nonatomic, strong) IBOutlet UIButton *verifyButton;
@property (nonatomic, strong) IBOutlet UIButton *skipButton;

@property (nonatomic, strong) IBOutlet UILabel *labelFacebook;
@property (nonatomic, strong) IBOutlet UILabel *labelWhyFacebook;
@property (nonatomic, strong) IBOutlet UIButton *facebookButton;

@property (nonatomic, strong) id <ADVAnimationController> animationController;

@end
