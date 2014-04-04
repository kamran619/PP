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
-(NSString *)getDayName:(int)day;

@property (weak, nonatomic) id <PCCScheduleHeaderDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftArrow;
@property (weak, nonatomic) IBOutlet UIButton *rightArrow;

@end
