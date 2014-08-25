//
//  PCCGenericRatingView.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCGenericRatingView : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message;
+ (instancetype)genericRatingViewWithTitle:(NSString *)title andMessage:(NSString *)message;

@end
