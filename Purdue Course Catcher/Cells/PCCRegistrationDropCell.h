//
//  PCCRegistrationCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCRegistrationDropCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *courseName;
@property (nonatomic, strong) IBOutlet UILabel *courseTitle;
@property (nonatomic, strong) IBOutlet UILabel *credits;

@property (nonatomic, strong) IBOutlet UIButton *dropButton;

@end
