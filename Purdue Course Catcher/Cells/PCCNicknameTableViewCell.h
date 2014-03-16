//
//  PCCNicknameCellTableViewCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/15/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCNicknameTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *textField;

@end
