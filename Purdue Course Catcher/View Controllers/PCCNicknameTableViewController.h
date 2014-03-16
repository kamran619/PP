//
//  PCCNicknameTableViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/15/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCNicknameTableViewCell.h"
@interface PCCNicknameTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet PCCNicknameTableViewCell *nicknameCell;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapGesture;

@end
