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
#import "PCCNicknameTableViewCell.h"

@interface PCCPurdueLoginViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet PCCNicknameTableViewCell *username;
@property (nonatomic, strong) IBOutlet PCCNicknameTableViewCell *password;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

- (void)moveControls:(direction)direction animated:(BOOL)animated;

@property (nonatomic, assign) PCCTermType type;


@end
