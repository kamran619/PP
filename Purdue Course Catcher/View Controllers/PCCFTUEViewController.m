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

#define NUMBER_OF_PAGES 4

@implementation PCCFTUEViewController
{
    NSInteger currentPage;
    BOOL firstTime;
    BOOL animating;
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
    [self initFTUE];
    if (self.fbLaunched == 1) {
        [self.scrollView setContentOffset:CGPointMake(320*NUMBER_OF_PAGES, 0) animated:NO];
        self.scrollView.scrollEnabled = NO;
    }else {
        firstTime = YES;
        self.animationController = [[DropAnimationController alloc] init];
        //[self.buttonYes addTarget:self action:@selector(showLogin:) forControlEvents:UIControlEventTouchUpInside];
        //[self.buttonNo addTarget:self action:@selector(scrollToRight:) forControlEvents:UIControlEventTouchUpInside];
        [self initAnimations];
        [self animateIn];

    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    animating = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self loggedIn]) {
        self.scrollView.scrollEnabled = YES;
        [self scrollToRight:nil];
    }
    
    if (!animating) [self moveBubble];
}

-(BOOL)loggedIn
{
    NSDictionary *dictionary = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kCredentials];
    return (dictionary!=nil);
}

- (void)initFTUE
{
    currentPage = 0;
    //init buttons
    self.purdueButton.layer.cornerRadius = 9.0f;
    self.facebookButton.layer.cornerRadius = 9.0f;
    //scrollview
    self.scrollView.backgroundColor = [Helpers purdueColor:PurdueColorMidGrey];
    [self.scrollView setScrollEnabled:NO];
    [self.scrollView setContentSize:CGSizeMake(320*(NUMBER_OF_PAGES+1), 0)];
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
    [self.skipButton addTarget:self action:@selector(skipFacebook:) forControlEvents:UIControlEventTouchUpInside];
#pragma clang diagnostic pop
    [self.purdueButton setBackgroundColor:[Helpers purdueColor:PurdueColorYellow]];
    self.mainBody.font = self.thirdLabel.font;
    self.subBody.font = self.thirdLabel.font;
    
    for (UILabel *label in self.scrollView.subviews) {
        if (label.tag == 0) continue;
        int xPosition = label.tag * 320;
        label.frame = CGRectOffset(label.frame, xPosition, 0);
    }
    
    //self.facebookButton.frame = CGRectOffset(self.facebookButton.frame, self.facebookButton.tag*320, 0);
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
    
    self.bigB.transform = t;
    self.bigBTwo.transform = t;
    
    t = CGAffineTransformMakeTranslation(0, 50);
    
    self.bubbles.transform = t;
    //self.bigP.transform = t;

    
}

-(void)animateIn
{
    animating = YES;
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
        self.bigB.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.bigBTwo.transform = CGAffineTransformIdentity;
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
                                    self.bubbles.alpha = 0.0f;
                                    [UIView animateWithDuration:0.45f animations:^{
                                        self.bubbles.alpha = 1.0f;
                                        self.bubbles.transform = CGAffineTransformIdentity;
                                    }completion:^(BOOL finished) {
                                        if (finished) [self performSelector:@selector(moveContentIn) withObject:nil afterDelay:0.75f];
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
    self.subBody.text = @"Verify you are affiliated with Purdue to proceed.";
}

-(void)flashButtons
{
    [UIView transitionWithView:self.purdueButton duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.purdueButton.alpha = 1.0f;
    }completion:^(BOOL finished) {
        if (finished) [self moveBubble];
    }];
}

-(void)moveBubble
{
    [UIView animateWithDuration:4.0f animations:^{
        self.bubbles.transform = CGAffineTransformTranslate(self.bubbles.transform, 0, -10);
    }completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:4.0f animations:^{
                self.bubbles.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                [self moveBubble];
            }];
        }
    }];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"animation"] isEqualToString:@"animationID"]) {
        //social animation
        [self performSelector:@selector(showSocial) withObject:nil afterDelay:2.5f];
    }else {
        if (flag) {
            [self flashButtons];
        }
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
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth);
    if (page < 0 || page >= self.pageControl.numberOfPages) return;
    self.pageControl.currentPage = page;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth);
    if (page ==  self.pageControl.numberOfPages-1) [self showSocial];
}

-(void)skipFacebook:(id)sender
{
    if (![Helpers hasRanAppBefore])  {
        //create settings dict for user
        [PCFNetworkManager sharedInstance].delegate = [UIApplication sharedApplication].delegate;
        [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReceivedFTUEComplete object:nil];
        //[Helpers requestFacebookIdentifier];
        //send fbid to server through notification
        [Helpers setHasRanAppBefore];
    }
}

-(void)showSocial
{
    NSArray *strings = @[@"Don't goto class often?", @"Not sure if there is homework due tomorrow?", @"Wanna form a study group?", @"Chat with peers or the entire class instantly!", @"Invite friends to take classes with you, or join a friends class!", @"Find peers by classification or major"];
    static int counter = 0;
    static BOOL once = NO;
    if (counter == strings.count) {
        if (!once) {
            [UIView transitionWithView:self.facebookButton duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                self.facebookButton.alpha = 1.0f;
                self.skipButton.alpha = 1.0f;
            }completion:nil];
            [self performSelector:@selector(showSocial) withObject:nil afterDelay:10.0f];
            once = true;
            return;
        }
    }
    
    CATransition *labelTransition = [CATransition animation];
    [labelTransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [labelTransition setFillMode:kCAFillModeBoth];
    [labelTransition setType:kCATransitionReveal];
    [labelTransition setSubtype:kCATransitionFromBottom];
    [labelTransition setDuration:.50f];
    [labelTransition setDelegate:self];
    self.socialText.alpha = 1.0f;
    [labelTransition setValue:@"animationID" forKey:@"animation"];
    [self.socialText.layer addAnimation:labelTransition forKey:@"SocialTransition"];
    [self.socialText setText:strings[counter++ % strings.count]];

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
    self.pageControl.hidden = NO;
    
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
