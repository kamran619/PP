//
//  PCCRegistrationHeaderViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/20/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCObject.h"

@interface PCCHeaderViewController : UIViewController

- (id)initWithTerm:(NSString *)term;
-(void)changeMessage:(NSString *)title message:(NSString *)message image:(NSString *)image;
-(void)changeMessage:(NSString *)title message:(NSString *)message;

-(void)slideIn:(UIView *)view;
-(void)slideOut;

-(void)dismissHeaderWithDuration:(CGFloat)duration;

@property (nonatomic, strong) IBOutlet UILabel *termHeader;
@property (nonatomic, strong) IBOutlet UILabel *detailLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) PCCObject *term;
@end
