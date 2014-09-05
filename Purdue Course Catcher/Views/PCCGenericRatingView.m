//
//  PCCGenericRatingView.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCGenericRatingView.h"

@implementation PCCGenericRatingView

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message {
    if (self = [super initWithFrame:CGRectZero]) {
        self.titleLabel = [[UILabel alloc] init];
        self.messageLabel = [[UILabel alloc] init];
        
        _titleLabel.text = title;
        _messageLabel.text = message;
        
        [self customizeView];
    }
    
    return self;
}

- (void)customizeView {
    [self addSubview:_titleLabel];
    [self addSubview:_messageLabel];
    
    [_titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [_titleLabel setBackgroundColor:[UIColor yellowColor]];
    [_messageLabel setBackgroundColor:[UIColor yellowColor]];
    
    [_messageLabel setNumberOfLines:0];
    
    [_messageLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    [_titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24.0f]];
    [_messageLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0f]];
}

+ (instancetype)genericRatingViewWithTitle:(NSString *)title andMessage:(NSString *)message {
    return [[PCCGenericRatingView alloc] initWithTitle:title andMessage:message];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (BOOL)translatesAutoresizingMaskIntoConstraints {
    return NO;
}

-(void)updateConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:35.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:30.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:-40.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_messageLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0f
                                                      constant:50.0f]];
    
    [super updateConstraints];
}

@end
