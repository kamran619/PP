//
//  PCCLeaveRatingViewController.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCLeaveRatingViewController : UIViewController

enum RatingPhase
{
    RatingPhaseOverall = 0,
    RatingPhaseHelpfulness,
    RatingPhaseClarity,
    RatingPhaseEasiness,
    RatingPhaseMessage,
    RatingPhaseMax
}typedef RatingPhase;

@property(nonatomic, assign) RatingPhase phase;
@property(nonatomic, strong) IBOutlet UILabel *mainLabel;
@property(nonatomic, strong) IBOutlet UILabel *detailLabel;
@property(nonatomic, strong) IBOutlet UIImageView *stars;
@property(nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;

@end
