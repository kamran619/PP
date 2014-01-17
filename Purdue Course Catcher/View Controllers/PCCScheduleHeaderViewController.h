//
//  PCCScheduleHeaderViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/22/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PCCScheduleHeaderDelegate <NSObject>
-(void)dayChangedTo:(NSString *)day;
-(void)animationDirectionChangedTo:(int)direction;
@end

@interface PCCScheduleHeaderViewController : UIViewController

-(NSString *)getCurrentDay;
- (void)springHeader;

@property (weak, nonatomic) id <PCCScheduleHeaderDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *labelMon;
@property (weak, nonatomic) IBOutlet UILabel *labelTue;
@property (weak, nonatomic) IBOutlet UILabel *labelWed;
@property (weak, nonatomic) IBOutlet UILabel *labelThur;
@property (weak, nonatomic) IBOutlet UILabel *labelFri;
@property (weak, nonatomic) IBOutlet UILabel *labelSat;
@property (weak, nonatomic) IBOutlet UILabel *labelSun;
@property (weak, nonatomic) IBOutlet UILabel *labelQuestion;

@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;

@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@property (weak, nonatomic) IBOutlet UIButton *circle;
@end
