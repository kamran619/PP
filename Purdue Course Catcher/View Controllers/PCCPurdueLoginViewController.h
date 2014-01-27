//
//  PCCPurdueLoginViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/8/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCTermViewController.h"
#import "Helpers.h"

@interface PCCPurdueLoginViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UILabel *mainTitle;
@property (nonatomic, strong) IBOutlet UILabel *detailInfo;
@property (nonatomic, strong) IBOutlet UILabel *becauseLabel;
@property (nonatomic, strong) IBOutlet UITextField *username;
@property (nonatomic, strong) IBOutlet UITextField *password;
@property (nonatomic, strong) IBOutlet UIButton *buttonWhy;
@property (nonatomic, strong) IBOutlet UIButton *buttonVerify;
@property (nonatomic, strong) IBOutlet UIButton *buttonDismiss;

- (void)moveControls:(direction)direction animated:(BOOL)animated;

@property (nonatomic, assign) PCCTermType type;


@end
