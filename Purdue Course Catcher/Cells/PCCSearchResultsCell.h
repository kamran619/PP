//
//  PCCSearchResultsCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCSearchResultsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *startTime;
@property (nonatomic, strong) IBOutlet UILabel *endTime;

@property (nonatomic, strong) IBOutlet UILabel *location;

@property (nonatomic, strong) IBOutlet UILabel *courseName;
@property (nonatomic, strong) IBOutlet UILabel *courseTitle;

@property (nonatomic, strong) IBOutlet UILabel *courseSection;
@property (nonatomic, strong) IBOutlet UILabel *courseType;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UILabel *days;

@property (nonatomic, strong) IBOutlet UILabel *contentDivider;
@property (nonatomic, strong) IBOutlet UILabel *timeDivider;

@property (nonatomic, strong) IBOutlet UILabel *credits;
@property (nonatomic, strong) IBOutlet UILabel *crn;
@property (nonatomic, strong) IBOutlet UILabel *slots;
@property (nonatomic, strong) IBOutlet UILabel *professor;
@property (nonatomic, strong) IBOutlet UIButton *emailProfessor;
@property (nonatomic, strong) IBOutlet UIButton *actionButton;
@property (nonatomic, strong) IBOutlet UIButton *ratingsButton;
@property (nonatomic, strong) IBOutlet UIButton *catalogButton;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)setupCatcher;
-(void)setupRegister;

@end
