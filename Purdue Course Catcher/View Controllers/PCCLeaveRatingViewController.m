//
//  PCCLeaveRatingViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCLeaveRatingViewController.h"

@interface PCCLeaveRatingViewController ()

@end

enum RatingPhase
{
    RatingPhaseOverall = 0,
    RatingPhaseHelpfulness,
    RatingPhaseClarity,
    RatingPhaseEasiness,
    RatingPhaseMessage,
    RatingPhaseMax
}typedef RatingPhase;


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
    [self updateRatingInformationWithPageNumber:pageNumber];
    //show new content
    CGFloat one = 1.0f;
    self.overallDetailLabel.alpha = one;
    self.overallHeader.alpha = one;
    self.overallStart.alpha = one;
}

- (void)updateRatingInformationWithPageNumber:(int)pageNumber {
    switch (pageNumber) {
        case RatingPhaseOverall:
            
            break;
        case RatingPhaseHelpfulness:
            break;
        case RatingPhaseClarity:
            break;
        case RatingPhaseEasiness:
            break;
        case RatingPhaseMax:
            break;
        default:
            break;
    }
}
@end
