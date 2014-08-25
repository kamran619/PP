//
//  PCCLeaveRatingViewController.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCLeaveRatingViewController.h"
@interface PCCLeaveRatingViewController : UIViewController<UIScrollViewDelegate>

//This is going to be an array of PCCGenericRating Objects
@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, strong) UIScrollView *scrollView;
@end
