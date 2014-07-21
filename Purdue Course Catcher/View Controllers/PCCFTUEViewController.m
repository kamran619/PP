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
#import "UIView+Animations.h"

@interface PCCFTUEViewController ()

@end

#define NUMBER_OF_PAGES 5

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
    [self initFTUE];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (firstTime == YES) {
        firstTime = NO;
        [self animateIn];
    }GI
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!firstTime) {
        if ([self loggedIn] == YES) {
            [Helpers setHasRanAppBefore];
            if ([Helpers getInitialization] == NO) {
                [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Registering..."];
            }else {
                if (!self.presentingViewController) {
                    [[UIApplication sharedApplication].delegate window].rootViewController = [Helpers viewControllerWithStoryboardIdentifier:@"PCCTabBar"];
                }else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.activePageIndicator.layer removeAllAnimations];
}

-(void)notificationWithName:(NSString *)name object:(id)object
{
    
}
-(BOOL)loggedIn
{
    return [Helpers getCurrentUser] != nil;
}

- (void)initFTUE
{
    currentPage = 0;
    firstTime = YES;
    self.animationController = [[DropAnimationController alloc] init];
    //init buttons
    self.loginButton.layer.cornerRadius = 9.0f;
    //self.facebookButton.layer.cornerRadius = 9.0f;
    //scrollview
    //self.scrollView.backgroundColor = [Helpers purdueColor:PurdueColorMidGrey];
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, self.scrollView.frame.size.height * (NUMBER_OF_PAGES))];
    //[self.pageControl setNumberOfPages:NUMBER_OF_PAGES];
    //UIView *view = [PCCFacebookLoginViewController sharedInstance].view;
    //CGRect offsetFrame = CGRectOffset(view.frame, 0, 0);
    //[view setFrame:offsetFrame];
    //[view setAlpha:0.0f];
    //[[PCCFacebookLoginViewController sharedInstance] willMoveToParentViewController:self];
    //[self.scrollView addSubview:view];
    //[self addChildViewController:[PCCFacebookLoginViewController sharedInstance]];
    //[[PCCFacebookLoginViewController sharedInstance] didMoveToParentViewController:self];
    //#pragma clang diagnostic push
    //#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //[self.facebookButton addTarget:[PCCFacebookLoginViewController sharedInstance] action:@selector(loginPushed:) forControlEvents:UIControlEventTouchUpInside];
    //[self.skipButton addTarget:self action:@selector(skipFacebook:) forControlEvents:UIControlEventTouchUpInside];
    //#pragma clang diagnostic pop
    [self.loginButton setBackgroundColor:[Helpers purdueColor:PurdueColorYellow]];
    //self.mainBody.font = self.thirdLabel.font;
    //self.subBody.font = self.thirdLabel.font;
    
    for (UILabel *label in self.scrollView.subviews) {
        if (label.tag == 0) continue;
        int yPosition = (label.frame.origin.y + self.scrollView.frame.size.height*label.tag);
        label.frame = CGRectOffset(label.frame, 0, yPosition);
    }
    
    CGRect frame = self.loginButton.frame;
    self.loginButton.frame = CGRectOffset(frame, 0, (NUMBER_OF_PAGES-1) * self.scrollView.frame.size.height);
    
    [self initAnimations];
    
    CGFloat height = self.view.frame.size.height/NUMBER_OF_PAGES;
    frame = self.activePageIndicator.frame;
    self.activePageIndicator.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    
    [self pageChanged:0];
    
    if ([Helpers isPhone5]) {

    }else {
        
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
    
    self.bigPFirst.transform = t;
    self.bigPSecond.transform = t;

    
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
        self.bigPFirst.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.35f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.bigPSecond.transform = CGAffineTransformIdentity;
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
                                [self performSelectorOnMainThread:@selector(moveContentIn) withObject:nil waitUntilDone:0.50f];
                            }];
                        }
                    }];
                }
            }];
}

-(void)toggleActivePage
{
    const int threshhold = 2;
    CGRect frame = self.activePageIndicator.frame;
    [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:5.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.activePageIndicator.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + threshhold);
    }completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.50f delay:0.0f usingSpringWithDamping:1.0f initialSpringVelocity:5.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveLinear animations:^{
                    CGRect frame = self.activePageIndicator.frame;
                    self.activePageIndicator.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - threshhold);
            }completion:^(BOOL finished) {
                if (finished) [self toggleActivePage];
            }];
        }
    }];
}
-(void)moveContentIn
{
    [self.activePageIndicator fadeIn];
    [self.inactivePageIndicator fadeIn];
    [self toggleActivePage];
    [self.scrollView fadeIn];
    [self transitionText:0 title:@"Welcome! " message:@"Swipe up to proceed"];
}

-(void)transitionText:(int)page title:(NSString *)titleText message:(NSString *)messageText
{
    CATransition *transition = [CATransition animation];
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [transition setFillMode:kCAFillModeBoth];
    [transition setType:kCATransitionPush];
    [transition setSubtype:kCATransitionFromBottom];
    [transition setDuration:0.75f];
    [transition setDelegate:self];
    //
    
    self.mainBody.text = @"";
    self.subBody.text = @"";
    
    if (page == NUMBER_OF_PAGES - 1) {
        self.mainBody.layer.transform = CATransform3DMakeTranslation(0, self.scrollView.frame.size.height * page, 0);
        self.subBody.layer.transform = CATransform3DMakeTranslation(0, self.scrollView.frame.size.height * page, 0);
        /*
         CGRect frame = self.mainBody.frame;
         self.mainBody.frame = CGRectMake(frame.origin.x, frame.origin.y + (self.scrollView.frame.size.height * page), frame.size.width, frame.size.height);
        frame = self.subBody.frame;
        self.subBody.frame = CGRectMake(frame.origin.x, frame.origin.y + (self.scrollView.frame.size.height * page), frame.size.width, frame.size.height);
         */
    }else {
        self.mainBody.layer.transform = CATransform3DIdentity;
        self.subBody.layer.transform = CATransform3DIdentity;
    }
    [transition setValue:[NSNumber numberWithInt:page] forKey:@"tag"];
    [self.mainBody.layer addAnimation:transition forKey:@"changeTextTransition"];
    self.mainBody.text = titleText;
    [self.subBody.layer addAnimation:transition forKey:@"changeTextTransition"];
    self.subBody.text = messageText;
}

-(void)flashButtons
{
    [UIView transitionWithView:self.loginButton duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        self.loginButton.alpha = 1.0f;
    }completion:^(BOOL finished) {
        //if (finished) [self moveBubble];
    }];
}

/*
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
*/

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"animation"] isEqualToString:@"animationID"]) {
        //social animation
    }else {
        if ([[anim valueForKey:@"tag"] isEqualToNumber:[NSNumber numberWithInt:NUMBER_OF_PAGES-1]]) {
            [self flashButtons];
        }else {
            self.loginButton.alpha = 0.0f;
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
    CGFloat pageHeight = scrollView.frame.size.height;
    int page = floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    if (page == currentPage) return;
    currentPage = page;
    [self pageChanged:page];
    if (page == 0) {
        [self transitionText:0 title:@"Welcome! " message:@"Swipe up to proceed"];
    }else if (page == NUMBER_OF_PAGES - 1) [self transitionText:page title:@"Verify you are affiliated with Purdue to continue." message:@""];
    else {
        self.mainBody.text = @"";
        self.subBody.text = @"";
        self.loginButton.alpha = 0.0f;
    }
}


/*
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageHeight = scrollView.frame.size.height;
    int page = floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    [self pageChanged:page];
    if (page == 0) {
        [self transitionText:0 title:@"Welcome! " message:@"Swipe up to proceed"];
    }else if (page == NUMBER_OF_PAGES - 1) [self transitionText:page title:@"" message:@"Verify you are affiliated with Purdue to continue."];
    //if (page ==  self.pageControl.numberOfPages-1) [self showSocial];
}
*/

-(void)pageChanged:(int)page
{
    [self.activePageIndicator.layer removeAllAnimations];
    CGFloat activePageSlice = self.view.frame.size.height/NUMBER_OF_PAGES;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationCurveLinear|UIViewAnimationOptionBeginFromCurrentState  animations:^{
            CGRect frame = self.activePageIndicator.frame;
            CGFloat height = activePageSlice + (page * activePageSlice);
            self.activePageIndicator.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    } completion:^(BOOL finished) {
        if (finished) [self toggleActivePage];
    }];
}

/*
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
*/
-(void)dismissMe
{
    if ([NSThread isMultiThreaded]) {
        [self performSelectorInBackground:@selector(dismissMe) withObject:nil];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
