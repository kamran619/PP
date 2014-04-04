//
//  PCCScheduleHeaderViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/22/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCScheduleHeaderViewController.h"

#define TRANLATE_DURATION 0.50f
@interface PCCScheduleHeaderViewController ()

@end

@implementation PCCScheduleHeaderViewController
{
    int currentDay;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initControl];
}

- (void)initControl
{
    currentDay = [self getDayOfWeek];
    self.dayLabel.text = [self getDayName:currentDay];
}

-(NSString *)getDayName:(int)day
{
    switch (day) {
        case 1:
            return @"Monday";
            break;
        case 2:
            return @"Tuesday";
            break;
        case 3:
            return @"Wednesday";
            break;
        case 4:
            return @"Thursday";
            break;
        case 5:
            return @"Friday";
            break;
        case 6:
            return @"Saturday";
            break;
        case 7:
            return @"Sunday";
            break;
        case 8:
            return @"Not Specified";
            break;
        default:
            return nil;
            break;
    }
}

-(NSString *)getCurrentDay
{
    switch (currentDay) {
        case 1:
            return @"M";
            break;
        case 2:
            return @"T";
            break;
        case 3:
            return @"W";
            break;
        case 4:
            return @"R";
            break;
        case 5:
            return @"F";
            break;
        case 6:
            return @"S";
            break;
        case 7:
            return @"U";
            break;
        case 8:
            return @"N/A";
            break;
        default:
            return nil;
            break;
    }
}


- (int)getDayOfWeek
{
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    return CFAbsoluteTimeGetDayOfWeek(at, tz);
}

- (IBAction)leftArrowPushed:(id)sender {
    
    int direction = 1;
    
    if (currentDay == 1) {
        currentDay = 8;
    }else {
        currentDay--;
    }
    
    if ([self.delegate respondsToSelector:@selector(dayChangedTo:)]) {
        [self transitionDay];
        [self.delegate dayChangedTo:[self getDayName:currentDay]];
    }
}

- (IBAction)rightArrowPushed:(id)sender {
    
    int direction = 0;
    if (currentDay == 8) {
        //[self pulseCircle];
        //[self performSelector:@selector(pulseCircle) withObject:nil afterDelay:TRANLATE_DURATION + .001];
        //return;
        //from right to left
        currentDay = 1;
    }else {
        currentDay++;
    }
    
    if ([self.delegate respondsToSelector:@selector(dayChangedTo:)]) {
        [self transitionDay];
        [self.delegate dayChangedTo:[self getDayName:currentDay]];
    }
}

-(void)transitionDay
{
    CATransition *labelTransition = [CATransition animation];
    [labelTransition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [labelTransition setFillMode:kCAFillModeBoth];
    [labelTransition setType:kCATransitionPush];
    [labelTransition setSubtype:kCATransitionFromBottom];
    [labelTransition setDuration:.50f];
    [labelTransition setDelegate:self];
    self.dayLabel.text = [self getDayName:currentDay];
    [self.dayLabel.layer addAnimation:labelTransition forKey:@"textChange"];
}

@end
