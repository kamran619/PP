//
//  PCCMainViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PCCMenuViewController.h"

//Views
#import "PCCSideMenuViewController.h"
#import "PCCScheduleViewController.h"
#import "PCCCatcherViewController.h"

#define CORNER_RADIUS 4

#define SLIDE_TIMING .18
#define PANEL_WIDTH 60

@interface PCCMenuViewController () 

@end

@implementation PCCMenuViewController

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
    [self setupInitialViewWithStoryboardIdentifier:@"PCCSearch"];
	// Do any additional setup after loading the view.
}

#pragma mark Convenience Methods

-(UIViewController *)viewControllerWithStoryboardIdentifier:(NSString *)identifier
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

-(void)resetMainView {
	// remove left and right views, and reset variables, if needed
	if (self.leftViewController != nil) {
		[self.leftViewController.view removeFromSuperview];
		self.leftViewController = nil;
		self.showingLeftPanel = NO;
	}
	if (self.rightViewController != nil) {
		[self.rightViewController.view removeFromSuperview];
		self.rightViewController = nil;
		self.showingRightPanel = NO;
	}
	// remove view shadows
	[self showCenterViewWithShadow:NO withOffset:0];
}

-(UIView *)getLeftView
{
    // init view if it doesn't already exist
	if (self.leftViewController == nil)
	{
		// this is where you define the view for the left panel
		self.leftViewController = [self viewControllerWithStoryboardIdentifier:@"PCCSideMenu"];
        
		[self.view addSubview:self.leftViewController.view];
        
		[self addChildViewController:self.leftViewController];
		[_leftViewController didMoveToParentViewController:self];
        
		_leftViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	self.showingLeftPanel = YES;
    
	// setup view shadows
	[self showCenterViewWithShadow:YES withOffset:-2];
    
	return self.leftViewController.view;
    
}

-(UIView *)getRightView {
	// init view if it doesn't already exist
	if (self.rightViewController == nil)
	{
		// this is where you define the view for the right panel
		self.rightViewController = [self viewControllerWithStoryboardIdentifier:@"PCCSettings"];
		
		[self.view addSubview:self.rightViewController.view];
		
		[self addChildViewController:self.rightViewController];
		[self.rightViewController didMoveToParentViewController:self];
		
		self.rightViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	self.showingRightPanel = YES;
    
	// setup view shadows
	[self showCenterViewWithShadow:YES withOffset:2];
    
	return self.rightViewController.view;
}

-(void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset {
	if (value) {
		[self.centralViewController.view.layer setCornerRadius:CORNER_RADIUS];
		[self.centralViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.centralViewController.view.layer setShadowOpacity:0.8];
		[self.centralViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
	} else {
		[self.centralViewController.view.layer setCornerRadius:0.0f];
		[self.centralViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    }
}

#pragma mark Initial Setup

- (void)setupInitialViewWithStoryboardIdentifier:(NSString *)identifier
{
    self.centralViewController = [self viewControllerWithStoryboardIdentifier:identifier];
	[self.view addSubview:self.centralViewController.view];
	[self addChildViewController:self.centralViewController];
	[self.centralViewController didMoveToParentViewController:self];
    
    [self setupGestures];
}

-(void)setupGestures
{
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
    
	[self.centralViewController.view addGestureRecognizer:panRecognizer];
}

#pragma mark Replacing Panels

-(void)replaceCenterViewControllerWithStoryboardIdentifier:(NSString *)identifier
{
    void (^block)() = ^{
        UIViewController *oldCenterVC = self.centralViewController;
        [self setupInitialViewWithStoryboardIdentifier:identifier];
        self.centralViewController.view.frame = CGRectMake(oldCenterVC.view.frame.origin.x, oldCenterVC.view.frame.origin.y, self.centralViewController.view.frame.size.width, self.centralViewController.view.frame.size.height);
        [oldCenterVC removeFromParentViewController];
        [oldCenterVC.view removeFromSuperview];
        //reanimate
        //move to left too far
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.centralViewController.view.frame = CGRectMake(-10, 0, self.view.frame.size.width, self.view.frame.size.height);
        }
        completion:^(BOOL finished) {
            if (finished) {
                [self movePanelToOriginalPosition];
            }
        }];
    };
    
    [self bouncePanelRightThenBackToOriginalPositionWithBlock:block];


}




#pragma mark - Panel Movement

-(void)movePanel:(UIPanGestureRecognizer *)sender {
    
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0) {
            if (!self.showingRightPanel) {
                childView = [self getLeftView];
            }
        } else {
            if (!self.showingLeftPanel) {
                childView = [self getRightView];
            }
			
        }
        // make sure the view we're working with is front and center
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if (!self.showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            if (self.showingLeftPanel) {
                [self movePanelRight];
            }  else if (self.showingRightPanel) {
                [self movePanelLeft];
            }
        }
	}
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
        self.showPanel = abs([sender view].center.x - self.centralViewController.view.frame.size.width/2) > self.centralViewController.view.frame.size.width/2;
        
        // allow dragging only in x coordinates by only updating the x coordinate with translation position
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [sender setTranslation:CGPointMake(0,0) inView:self.view];
        
	}
}

#pragma mark Animations
-(void)bouncePanelRightThenBackToOriginalPositionWithBlock:(void(^)(void))block
{
    
	[UIView animateWithDuration:SLIDE_TIMING/2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centralViewController.view.frame = CGRectMake(self.view.frame.size.width + 1, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished){
        if (finished) {
            //execute our black to change vc's
            if (block) block();
        }
    }];
}

-(void)movePanelLeft {
    [self movePanelLeftWithCompletionBlock:nil];
}

-(void)movePanelLeftWithCompletionBlock:(void(^)(void))block
{
    UIView *childView = [self getRightView];
	[self.view sendSubviewToBack:childView];
    
	[UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centralViewController.view.frame = CGRectMake(-self.view.frame.size.width + PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished){
        if (finished) if (block) block();
    }];
}

-(void)movePanelRight
{
    [self movePanelRightWithCompletionBlock:nil];
}

-(void)movePanelRightWithCompletionBlock:(void(^)(void))block
{
    UIView *childView = [self getLeftView];
	[self.view sendSubviewToBack:childView];
    
	[UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centralViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished) {
        if (finished) if (block) block();
    }];
}

-(void)movePanelToOriginalPosition
{
    [self movePanelToOriginalPositionWithCompletionBlock:nil];
}

-(void)movePanelToOriginalPositionWithCompletionBlock:(void(^)(void))block {
	[UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.centralViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                             if (block) block();
                         }
                     }];
}



@end
