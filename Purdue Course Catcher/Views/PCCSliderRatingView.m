//
//  PCCSliderRatingView.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/27/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCSliderRatingView.h"

@implementation PCCSliderRatingView

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message andData:(NSArray *)data {
    if (self = [super initWithTitle:title andMessage:message]) {
        self.dataSource = data;
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
        _slider.minimumValue = 0;
        _slider.maximumValue = data.count - 1;
        
        _sliderString = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [self customizeViews];
    }
    
    return self;
}

+ (instancetype)genericRatingViewWithTitle:(NSString *)title andMessage:(NSString *)message andDate:(NSArray *)data {
    return [[PCCSliderRatingView alloc] initWithTitle:title andMessage:message andData:data];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (BOOL)translatesAutoresizingMaskIntoConstraints {
    return NO;
}

- (void)customizeViews {
    _slider.translatesAutoresizingMaskIntoConstraints = NO;
    _sliderString.translatesAutoresizingMaskIntoConstraints = NO;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_sliderString setBackgroundColor:[UIColor yellowColor]];
    [_sliderString setTextAlignment:NSTextAlignmentCenter];
    [_sliderString setNumberOfLines:0];
    [_sliderString setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f]];
    //set string as default value
    [_sliderString setText:_dataSource[0]];
    
    [self addSubview:_slider];
    [self addSubview:_sliderString];
    
}

- (void)sliderChanged:(UISlider *)slider {
    [_sliderString setText:_dataSource[(int)slider.value]];
}

-(void)updateConstraints {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_slider
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_slider
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_slider
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:200.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderString
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_slider
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderString
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_slider
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:30.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderString
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:200.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_sliderString
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:30.0f]];
    
    [super updateConstraints];
}
@end
