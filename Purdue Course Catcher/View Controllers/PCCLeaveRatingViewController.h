//
//  PCCLeaveRatingViewController.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCLeaveRatingViewController : UIViewController<UIScrollViewDelegate>


@property(nonatomic, assign) RatingPhase phase;
@property(nonatomic, strong) IBOutlet UILabel *overallHeader;
@property(nonatomic, strong) IBOutlet UILabel* overallDetailLabel;
@property(nonatomic, strong) IBOutlet UIImageView *overallStart;
@property(nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;

@end
