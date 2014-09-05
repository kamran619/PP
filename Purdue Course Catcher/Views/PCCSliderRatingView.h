//
//  PCCSliderRatingView.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/27/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCGenericRatingView.h"

@interface PCCSliderRatingView : PCCGenericRatingView

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message andData:(NSArray *)data;
+ (instancetype)genericRatingViewWithTitle:(NSString *)title andMessage:(NSString *)message andDate:(NSArray *)data;
- (void)sliderChanged:(UISlider *)slider;

@property(nonatomic, strong) NSArray *dataSource;
@property(nonatomic, strong) UISlider *slider;
@property(nonatomic, strong) UILabel *sliderString;
@end
