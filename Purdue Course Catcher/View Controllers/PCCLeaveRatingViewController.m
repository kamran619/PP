//
//  PCCLeaveRatingViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCLeaveRatingViewController.h"
#import "PCCGenericRating.h"
#import "PCCGenericRatingView.h"

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
    self.dataSource = @[ [[PCCGenericRating alloc] initWithTitle:@"Easiness" andMessage:@"WHAT A JOKERRRR" andVariatons:nil],
                         [[PCCGenericRating alloc] initWithTitle:@"Overall"  andMessage:@"HAHAHAHAHAAHHAHAHAHHAHA LIKE Y(UOOOO PUSSSUYUY" andVariatons:nil]
                       ];
    [self initView];
}

- (void)initView {
    CGFloat navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    CGFloat heightDifference = navigationBarHeight + statusBarHeight;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    
    //setup constraints
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.view
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                   multiplier:1.0f
                                                                                     constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0f
                                                           constant:-heightDifference]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:self.view
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0f constant:0.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f constant:0.0]];
    
    
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PCCGenericRating *rating = (PCCGenericRating *)obj;
        PCCGenericRatingView *ratingView = [self createViewWithRating:rating];
        [self.scrollView addSubview:ratingView];
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.scrollView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0f
                                                                     constant:0.0f]];
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.scrollView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0f
                                                                     constant:0.0f]];
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.scrollView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1.0f
                                                                     constant:0.0f]];
        
        CGFloat multiplier = (idx == 0) ? 1.0f : (idx + 1.0f);
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:ratingView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.scrollView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:multiplier
                                                                     constant:0.0f]];
        
    }];
}

- (PCCGenericRatingView *)createViewWithRating:(PCCGenericRating *)rating {
    PCCGenericRatingView *view = [PCCGenericRatingView genericRatingViewWithTitle:rating.title andMessage:rating.message];
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
