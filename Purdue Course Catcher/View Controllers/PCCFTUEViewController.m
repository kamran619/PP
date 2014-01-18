//
//  PCCFTUEViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCFTUEViewController.h"
#import "PCCDataManager.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "KPLightBoxManager.h"
#import "PCCHUDManager.h"
#import "PCCPurdueLoginViewController.h"
#import "PCCFacebookLoginViewController.h"
#import "DropAnimationController.h"

@interface PCCFTUEViewController ()

@end

#define NUMBER_OF_PAGES 3
@implementation PCCFTUEViewController
{
    NSInteger currentPage;
    BOOL firstTime;
}

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
    firstTime = YES;
    self.animationController = [[DropAnimationController alloc] init];
    //[self.buttonYes addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
    //[self.buttonNo addTarget:self action:@selector(scrollToRight:) forControlEvents:UIControlEventTouchUpInside];
    [self initFTUE];
    [self initAnimations];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self animateIn];
    if (firstTime == YES) {
        firstTime = NO;
    }else if (!firstTime) {
        [self scrollToRight:nil];
    }
}
- (void)initFTUE
{
    currentPage = 0;
    self.facebookButton.layer.cornerRadius = 9.0f;
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320*NUMBER_OF_PAGES, self.view.frame.size.height)];
    [self.pageControl setNumberOfPages:NUMBER_OF_PAGES];
    UIView *view = [PCCFacebookLoginViewController sharedInstance].view;
    CGRect offsetFrame = CGRectOffset(view.frame, 0, 0);
    [view setFrame:offsetFrame];
    [view setAlpha:0.0f];
    [[PCCFacebookLoginViewController sharedInstance] willMoveToParentViewController:self];
    [self.scrollView addSubview:view];
    [self addChildViewController:[PCCFacebookLoginViewController sharedInstance]];
    [[PCCFacebookLoginViewController sharedInstance] didMoveToParentViewController:self];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.facebookButton addTarget:[PCCFacebookLoginViewController sharedInstance] action:@selector(loginPushed:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
}

- (void)initAnimations
{
    CGAffineTransform rotate = CGAffineTransformMakeRotation(RADIANS(25));
    CGAffineTransform rotateTwo = CGAffineTransformMakeRotation(RADIANS(-25));
    self.firstLabel.transform = rotate;
    self.secondLabel.transform = rotateTwo;
    self.thirdLabel.transform = rotate;
    
    
    self.firstLabel.alpha = 0.0f;
    self.secondLabel.alpha = 0.0f;
    self.thirdLabel.alpha = 0.0f;
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(0, -250);
    
    self.bigCTwo.transform = t;
    self.bigC.transform = t;
    self.bigP.transform = t;

    
}

-(void)animateIn
{
    /*
    [UIView animateKeyframesWithDuration:1.75f delay:0.0f options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0f relativeDuration:0.25 animations:^{
            self.bigP.transform = CGAffineTransformIdentity;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.25f relativeDuration:0.25 animations:^{
            self.bigC.transform = CGAffineTransformIdentity;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.50f relativeDuration:0.25 animations:^{
            self.bigCTwo.transform = CGAffineTransformIdentity;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.75f relativeDuration:0.25 animations:^{
            self.bigP.transform = CGAffineTransformIdentity;
        }];
        [UIView addKeyframeWithRelativeStartTime:1.0f relativeDuration:0.75 animations:^{
            self.firstLabel.alpha = 1.0f;
            self.firstLabel.transform = CGAffineTransformIdentity;
            self.secondLabel.alpha = 1.0f;
            self.secondLabel.transform = CGAffineTransformIdentity;
            self.thirdLabel.alpha = 1.0f;
            self.thirdLabel.transform = CGAffineTransformIdentity;
        }];
        
        
    }completion:^(BOOL finished) {
        
    }];
    */
     
    [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.bigP.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.bigC.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.bigCTwo.transform = CGAffineTransformIdentity;
                    }completion:^(BOOL finished) {
                        if (finished) {
                            [UIView animateWithDuration:0.45f delay:0.0f usingSpringWithDamping:0.2f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                self.firstLabel.alpha = 1.0f;
                                self.firstLabel.transform = CGAffineTransformIdentity;
                                self.secondLabel.alpha = 1.0f;
                                self.secondLabel.transform = CGAffineTransformIdentity;
                                self.thirdLabel.alpha = 1.0f;
                                self.thirdLabel.transform = CGAffineTransformIdentity;
                            }completion:^(BOOL finished) {
                                if (finished) {
                                    [self moveContentIn];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];

}

-(void)moveContentIn
{
    
    CATransition *transition = [CATransition animation];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [transition setFillMode:kCAFillModeBoth];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromBottom];
    [transition setDuration:0.75f];
    [transition setDelegate:self];
    //
    [self.mainBody.layer addAnimation:transition forKey:@"changeTextTransition"];
    self.mainBody.text = @"Welcome! ";
    [self.subBody.layer addAnimation:transition forKey:@"changeTextTransition"];
    self.subBody.text = @"Login with Facebook to proceed.";
}

-(void)flashButtons
{
    /*CATransition *buttonTransition = [CATransition animation];
    [buttonTransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [buttonTransition setFillMode:kCAFillModeBoth];
    [buttonTransition setType:kCATransitionReveal];
    [buttonTransition setSubtype:kCATransitionFromTop];
    [buttonTransition setDuration:.50f];
    [buttonTransition setTimeOffset:0.0f];
     [self.facebookButton.layer addAnimation:buttonTransition forKey:@"changeTextTransition"];
     [self.facebookButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
     
    */
    [UIView transitionWithView:self.facebookButton duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.facebookButton.alpha = 1.0f;
    }completion:nil];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        [self flashButtons];
    }
}

-(IBAction)showLogin:(id)sender
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PCCPurdueLoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PCCPurdueLogin"];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page < 0 || page >= self.pageControl.numberOfPages) return;
    self.pageControl.currentPage = page;
}

-(void)dismissMe
{
    if ([NSThread isMultiThreaded]) {
        [self performSelectorInBackground:@selector(dismissMe) withObject:nil];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)scrollToRight:(id)sender
{
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
    
}

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
