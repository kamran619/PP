//
//  PCCMainViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCMenuViewController : UIViewController <UIGestureRecognizerDelegate>

-(id)initCentralViewControllerWithViewController:(id)vc;
-(id)initCentralViewControllerWithIdentifier:(NSString *)vc;

@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, strong) UIViewController *centralViewController;

@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

-(void)replaceCenterViewControllerWithStoryboardIdentifier:(NSString *)identifier;
-(void)replaceCenterViewControllerWithViewController:(id)vc animated:(BOOL)animated;
- (void)setupInitialViewWithViewController:(id)vc;
- (void)setupInitialViewWithStoryboardIdentifier:(NSString *)identifier;

@end
