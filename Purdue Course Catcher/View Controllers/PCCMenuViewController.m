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
#import "Helpers.h"

#import "KPLightBoxManager.h"

#define CORNER_RADIUS 4

#define SLIDE_TIMING 0.75f
#define PANEL_WIDTH 30

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

-(id)initCentralViewControllerWithIdentifier:(NSString *)vc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!vc) {
            [self setupInitialViewWithStoryboardIdentifier:@"PCCSearch"];
        }else {
            [self setupInitialViewWithStoryboardIdentifier:vc];
        }
    }
    
    return self;

}

-(id)initCentralViewControllerWithViewController:(id)vc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setupInitialViewWithViewController:vc];
    }
    
    return self;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


#pragma mark Convenience Methods


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
    
     [self.centralViewController.view removeGestureRecognizer:self.tapGesture];
    
	// remove view shadows
	[self showCenterViewWithShadow:NO withOffset:0];
}

-(UIView *)getLeftView
{
    // init view if it doesn't already exist
	if (self.leftViewController == nil)
	{
		// this is where you define the view for the left panel
		self.leftViewController = [Helpers viewControllerWithStoryboardIdentifier:@"PCCSideMenu"];
        
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
		self.rightViewController = [Helpers viewControllerWithStoryboardIdentifier:@"PCCSettings"];
		
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
	/*if (value) {
		[self.centralViewController.view.layer setCornerRadius:CORNER_RADIUS];
		[self.centralViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
		[self.centralViewController.view.layer setShadowOpacity:0.8];
		[self.centralViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
	} else {
		[self.centralViewController.view.layer setCornerRadius:0.0f];
		[self.centralViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    }*/
}

#pragma mark Initial Setup

- (void)setupInitialViewWithStoryboardIdentifier:(NSString *)identifier
{
    
    self.centralViewController = [Helpers viewControllerWithStoryboardIdentifier:identifier];
	[self.view addSubview:self.centralViewController.view];
	[self addChildViewController:self.centralViewController];
	[self.centralViewController didMoveToParentViewController:self];
    
    [self setupGestures];
}

- (void)setupInitialViewWithViewController:(id)vc
{
    [self.centralViewController.view removeFromSuperview];
    self.centralViewController = vc;
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
    [panRecognizer setCancelsTouchesInView:NO];
    
	[self.centralViewController.view addGestureRecognizer:panRecognizer];
}

-(void)addTap
{
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self.tapGesture setNumberOfTapsRequired:1];
        [self.tapGesture setNumberOfTouchesRequired:1];
        [self.tapGesture setDelegate:self];
        [self.tapGesture setCancelsTouchesInView:YES];
    }
    
    [self.centralViewController.view addGestureRecognizer:self.tapGesture];
}

-(void)tapped:(UITapGestureRecognizer *)gesture
{
    [self movePanelToOriginalPosition];
}

#pragma mark Replacing Panels

-(void)replaceCenterViewControllerWithStoryboardIdentifier:(NSString *)identifier
{
    void (^block)();
    
    if ([self.centralViewController.restorationIdentifier isEqualToString:identifier]) {
        block = ^{
            [UIView animateWithDuration:SLIDE_TIMING/2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.centralViewController.view.frame = CGRectMake(-10, 0, self.view.frame.size.width, self.view.frame.size.height);
            }completion:^(BOOL finished) {
                    if (finished) {
                        [self.centralViewController viewWillAppear:YES];
                        [[KPLightBoxManager sharedInstance] dismissLightBox];
                        [self movePanelToOriginalPosition];
                    }
            }];
        };
    }else {
        block = ^{
            UIViewController *oldCenterVC = self.centralViewController;
            [self setupInitialViewWithStoryboardIdentifier:identifier];
            self.centralViewController.view.frame = CGRectMake(oldCenterVC.view.frame.origin.x, oldCenterVC.view.frame.origin.y, self.centralViewController.view.frame.size.width, self.centralViewController.view.frame.size.height);
            [oldCenterVC removeFromParentViewController];
            [oldCenterVC.view removeFromSuperview];
            //reanimate
            //move to left too far
            [UIView animateWithDuration:SLIDE_TIMING/2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.centralViewController.view.frame = CGRectMake(-10, 0, self.view.frame.size.width, self.view.frame.size.height);
            }completion:^(BOOL finished) {
                if (finished) {
                    [self movePanelToOriginalPosition];
                }
            }];
        };
    }
    
    
    
    [self bouncePanelRightThenBackToOriginalPositionWithBlock:block];


}

-(void)replaceCenterViewControllerWithViewController:(id)vc animated:(BOOL)animated
{
    void (^block)();
    
        block = ^{
            UIViewController *oldCenterVC = self.centralViewController;
            [self setupInitialViewWithViewController:vc];
            self.centralViewController.view.frame = CGRectMake(oldCenterVC.view.frame.origin.x, oldCenterVC.view.frame.origin.y, self.centralViewController.view.frame.size.width, self.centralViewController.view.frame.size.height);
            [oldCenterVC removeFromParentViewController];
            [oldCenterVC.view removeFromSuperview];
            //reanimate
            //move to left too far
            if (animated) {
                [UIView animateWithDuration:SLIDE_TIMING/2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.centralViewController.view.frame = CGRectMake(-10, 0, self.view.frame.size.width, self.view.frame.size.height);
                }completion:^(BOOL finished) {
                    if (finished) {
                        [self movePanelToOriginalPosition];
                    }
                }];
            }else {
                 self.centralViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            }
            
        };
    
    
    [self bouncePanelRightThenBackToOriginalPositionWithBlock:block];
    
    
}




#pragma mark - Panel Movement

-(void)adjustPanel
{
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
        
        [self adjustPanel];
    }
    
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        // are we more than halfway, if so, show the panel when done dragging by setting this value to YES (1)
        if (self.showingLeftPanel == YES && velocity.x < 0) {
            self.showPanel = NO;
        }else if (self.showingRightPanel == YES && velocity.x > 0) {
            self.showPanel = NO;
        }else {
            self.showPanel = (abs(velocity.x) > 150 || abs([sender view].center.x - self.centralViewController.view.frame.size.width/2) > self.centralViewController.view.frame.size.width/3);
        }
        
        // allow dragging only in x coordinates by only updating the x coordinate with translation position
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [sender setTranslation:CGPointMake(0,0) inView:self.view];
        
	}
}

#pragma mark Animations
-(void)bouncePanelRightThenBackToOriginalPositionWithBlock:(void(^)(void))block
{
    
	[UIView animateWithDuration:SLIDE_TIMING/8 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.centralViewController.view.frame = CGRectMake(self.view.frame.size.width + 1, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished){
        if (finished) {
            //execute our black to change vc's
            if (block) block();
        }
    }];
}


-(void)bouncePanelLeftThenBackToOriginalPositionWithBlock:(void(^)(void))block
{
    
	[UIView animateWithDuration:SLIDE_TIMING/8 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.centralViewController.view.frame = CGRectMake(-10, 0, self.view.frame.size.width, self.view.frame.size.height);
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
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.centralViewController.view.frame = CGRectMake(-self.view.frame.size.width + PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished ) {
        if (finished) {
            [self addTap];
            if (block) block();
        }
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
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0.0f usingSpringWithDamping:0.5f initialSpringVelocity:10.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.centralViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished ) {
        if (finished) {
            [self addTap];
            if (block) block();
        }
    }];
    
}

-(void)movePanelToOriginalPosition
{
    [self movePanelToOriginalPositionWithCompletionBlock:nil];
}

-(void)movePanelToOriginalPositionWithCompletionBlock:(void(^)(void))block {
    
    [UIView animateWithDuration:SLIDE_TIMING/2 delay:0.0f usingSpringWithDamping:0.75f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:^{
        self.centralViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }completion:^(BOOL finished ) {
        if (finished) {
            [self resetMainView];
            if (block) block();
        }
    }];
    
}



@end
