//
//  PCCLeaveRatingViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCLeaveRatingViewController.h"
#import "PCCGenericRating.h"
#import "PCCSliderRatingView.h"

@interface PCCLeaveRatingViewController ()

@end

@implementation PCCLeaveRatingViewController

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
    self.dataSource = @[ [[PCCGenericRating alloc] initWithTitle:@"Easiness"
                                                      andMessage:@"WHAT A JOKERRRR"
                                                    andVariatons:@[ @"very easy", @"easy", @"moderate", @"hard", @"very hard"]],
                         
                         [[PCCGenericRating alloc] initWithTitle:@"Joker"
                                                      andMessage:@"WHAT A fuck"
                                                    andVariatons:@[ @"very easy", @"easy", @"moderate", @"hard", @"very hard"]],
                         
                         [[PCCGenericRating alloc] initWithTitle:@"Difficulty"
                                                      andMessage:@"YOu are not difficult at all"
                                                    andVariatons:@[ @"very easy", @"easy", @"moderate", @"hard", @"very hard"]]
                       ];
    
    [self initView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSArray *array = [self.containerView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal];
    for (UIView *view in self.containerView.subviews) {
        NSArray *constraints = [view constraintsAffectingLayoutForAxis:UILayoutConstraintAxisHorizontal];
    }
    
}
- (void)initView {
    [self setupConstraints];
    [self addChildrenViewControllersWithConstraints];
    
}

- (void)setupConstraints {
    CGRect windowFrame = [[UIApplication sharedApplication].delegate window].frame;
    CGFloat windowWidth = windowFrame.size.width * self.dataSource.count;
    
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0f
                                                                        constant:windowWidth]];
}

- (void)addChildrenViewControllersWithConstraints {
    __block PCCGenericRatingView *previousView = nil;
    
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PCCGenericRating *rating = (PCCGenericRating *)obj;
        PCCGenericRatingView *ratingView = [self createViewWithRating:rating];
        [_containerView addSubview:ratingView];
        
        NSDictionary *dictionaryOfViews;
        
        if (previousView) {
            dictionaryOfViews = NSDictionaryOfVariableBindings(ratingView, previousView);
        }else {
            dictionaryOfViews = NSDictionaryOfVariableBindings(ratingView);
        }
        CGRect windowSize = [[UIApplication sharedApplication].delegate window].frame;
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1.0f
                                                          constant:windowSize.size.width]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_containerView
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0f
                                                                    constant:0.0f]];
        
        [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_containerView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0f
                                                                    constant:0.0f]];
        
        if (!previousView) {
//            [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[ratingView]|" options:0 metrics:nil views:dictionaryOfViews]];
            [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_containerView
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1.0f
                                                                        constant:0.0f]];
        }else if (idx == self.dataSource.count - 1) {
//            [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previousView]-(0)-|" options:0 metrics:nil views:dictionaryOfViews]];
            [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:_containerView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0f
                                                                        constant:0.0f]];
        }else {
//            [_containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previousView][ratingView]|" options:0 metrics:nil views:dictionaryOfViews]];
            [_containerView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:previousView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0f
                                                                        constant:0.0f]];
        }
        
        [ratingView setAlpha:0.3];
        previousView = ratingView;
        [self.view layoutIfNeeded];
    }];
}

- (PCCGenericRatingView *)createViewWithRating:(PCCGenericRating *)rating {
    PCCGenericRatingView *view = [PCCGenericRatingView genericRatingViewWithTitle:rating.title andMessage:rating.message];
    [view setBackgroundColor:[UIColor redColor]];
    return view;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIScrollViewDelegate methods

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat currentContentOffset = [scrollView contentOffset].x;
    int pageNumber = floor(scrollView.contentSize.width/currentContentOffset);
    //show new content
}

@end
