//
//  PCCRegistrationCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/23/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCRegistrationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *days;
@property (nonatomic, strong) IBOutlet UILabel *time;
@property (nonatomic, strong) IBOutlet UILabel *instructor;
@property (nonatomic, strong) IBOutlet UILabel *location;

@end
