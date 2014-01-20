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
    [self moveBallToDay:currentDay animated:NO];
}

-(UILabel *)getLabelOfDay
{
    switch (currentDay) {
        case 1:
            return self.labelMon;
            break;
        case 2:
            return self.labelTue;
            break;
        case 3:
            return self.labelWed;
            break;
        case 4:
            return self.labelThur;
            break;
        case 5:
            return self.labelFri;
            break;
        case 6:
            return self.labelSat;
            break;
        case 7:
            return self.labelSun;
            break;
        case 8:
            return self.labelQuestion;
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
#pragma mark Move Ball

- (void)moveBallToDay:(int)day animated:(BOOL)animated
{
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(dayChangedTo:)]) [self.delegate dayChangedTo:[self getCurrentDay]];
    }
    
    CGPoint moveTo;
    
    switch (day) {
        case 1:
            moveTo = self.labelMon.center;
            break;
        case 2:
            moveTo = self.labelTue.center;
            break;
        case 3:
            moveTo = self.labelWed.center;
            break;
        case 4:
            moveTo = self.labelThur.center;
            break;
        case 5:
            moveTo = self.labelFri.center;
            break;
        case 6:
            moveTo = self.labelSat.center;
            break;
        case 7:
            moveTo = self.labelSun.center;
            break;
        case 8:
            moveTo = self.labelQuestion.center;
            break;
        default:
            break;
    }
    
    if (!animated) {
        self.circle.center = moveTo;
        [self changeColors];
        return;
    }
    
    [self pulseCircle];
    [UIView animateWithDuration:TRANLATE_DURATION delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.circle.center = moveTo;
        [self getLabelOfDay].textColor = [UIColor blackColor];
    }completion:^(BOOL finished) {
        if (finished) {
            currentDay = day;
            [UIView animateWithDuration:TRANLATE_DURATION/3 animations:^{
                [self changeColors];
                [self pulseCircle];
            }];
        }
    }];

}


- (int)getDayOfWeek
{
    CFAbsoluteTime at = CFAbsoluteTimeGetCurrent();
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    return CFAbsoluteTimeGetDayOfWeek(at, tz);
}

- (void)changeColors
{
    [UIView animateWithDuration:TRANLATE_DURATION/3 animations:^{
        switch (currentDay) {
            case 1:
                self.labelMon.textColor = [UIColor whiteColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 2:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor whiteColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 3:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor whiteColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 4:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor whiteColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 5:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor whiteColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 6:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor whiteColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 7:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor whiteColor];
                self.labelQuestion.textColor = [UIColor blackColor];
                break;
            case 8:
                self.labelMon.textColor = [UIColor blackColor];
                self.labelTue.textColor = [UIColor blackColor];
                self.labelWed.textColor = [UIColor blackColor];
                self.labelThur.textColor = [UIColor blackColor];
                self.labelFri.textColor = [UIColor blackColor];
                self.labelSat.textColor = [UIColor blackColor];
                self.labelSun.textColor = [UIColor blackColor];
                self.labelQuestion.textColor = [UIColor whiteColor];
                break;
            default:
                break;
        }
    }];
}

- (void)pulseCircle
{
    __block UILabel *day = [self getLabelOfDay];
    [UIView animateWithDuration:TRANLATE_DURATION/2 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.circle.layer.transform = CATransform3DMakeScale(1.35f, 1.35f, 1);
        day.transform = CGAffineTransformMakeScale(1.35f, 1.35f);
    }completion:^(BOOL finished) {
            [UIView animateWithDuration:TRANLATE_DURATION/2 animations:^{
                self.circle.layer.transform = CATransform3DIdentity;
                day.transform = CGAffineTransformIdentity;
            }];
    }];
}

- (void)springHeader
{
    [self initControl];
    [self getLabelOfDay].textColor = [UIColor blackColor];
    [self.leftArrow setAlpha:0.0f];
    [self.rightArrow setAlpha:0.0f];
    [self.headerTitle setAlpha:0.0f];
    [UIView animateWithDuration:.3f delay:0.00f usingSpringWithDamping:0.8f initialSpringVelocity:1.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.headerTitle.transform = CGAffineTransformMakeTranslation(-20, 0);
        self.circle.transform = CGAffineTransformMakeTranslation(-20, 0);
    }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15f animations:^{
                self.headerTitle.transform = CGAffineTransformIdentity;
                self.circle.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5f animations:^{
                        [self getLabelOfDay].textColor = [UIColor whiteColor];
                        [self.leftArrow setAlpha:1.0f];
                        [self.rightArrow setAlpha:1.0f];
                        [self.headerTitle setAlpha:1.0f];
                    }];
            }];
    }];
}
- (IBAction)leftArrowPushed:(id)sender {
    
    int direction = 1;
    
    if (currentDay == 7) {
        //[self pulseCircle];
        //[self performSelector:@selector(pulseCircle) withObject:nil afterDelay:TRANLATE_DURATION + .001];
        //return;
        currentDay = 8;
    }else if (currentDay == 1){
        currentDay = 7;
    }else if (currentDay == 8) {
        currentDay = 6;
    }else {
        currentDay--;
    }
    
    if ([self.delegate respondsToSelector:@selector(animationDirectionChangedTo:)]) {
        [self.delegate animationDirectionChangedTo:direction];
    }
    
    //special case
    if (currentDay == 8) {
        //if we are at 8 we change the frame to be the the right of the button
        CGRect circleFrame = self.circle.frame;
        
        CGRect frame = CGRectOffset(circleFrame, -20, 0);
        CGRect frameFinal = CGRectMake(self.labelQuestion.frame.origin.x + 30, self.labelQuestion.frame.origin.y, circleFrame.size.width, circleFrame.size.height);//(self.labelQuestion.frame, 30, 0);
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(dayChangedTo:)]) [self.delegate dayChangedTo:[self getCurrentDay]];
        }
        [self pulseCircle];
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.circle.frame = frame;
        }completion:^(BOOL finished) {
            if (finished) {
                self.circle.alpha = 0.0f;
                self.circle.frame = frameFinal;
                [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                    self.circle.center = self.labelQuestion.center;
                    self.circle.alpha = 1.0f;
                }completion:^(BOOL finished) {
                    if (finished) {
                        [UIView animateWithDuration:0.25f animations:^{
                            [self changeColors];
                            [self pulseCircle];
                        }];
                    }
                }];
            }
        }];
    }else {
        [self moveBallToDay:currentDay animated:YES];
    }
}

- (IBAction)rightArrowPushed:(id)sender {
    
    int direction = 0;
    if (currentDay == 8) {
        //[self pulseCircle];
        //[self performSelector:@selector(pulseCircle) withObject:nil afterDelay:TRANLATE_DURATION + .001];
        //return;
        //from right to left
        currentDay = 7;
    }else if (currentDay == 6) {
        currentDay = 8;
    }else if (currentDay == 7) {
        currentDay = 1;
    }else {
        currentDay++;
    }
    if ([self.delegate respondsToSelector:@selector(animationDirectionChangedTo:)]) {
        [self.delegate animationDirectionChangedTo:direction];
    }
    
    //special case
    if (currentDay == 7) {
        //move off the screen to the right
        CGRect frame = CGRectMake(self.circle.frame.origin.x + 60, self.circle.frame.origin.y, self.circle.frame.size.width, self.circle.frame.size.height);
        //move to the left of the screen so we can animate it in
        CGRect frameFinal = CGRectMake(-20, self.circle.frame.origin.y, self.circle.frame.size.width, self.circle.frame.size.height);
        
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(dayChangedTo:)]) [self.delegate dayChangedTo:[self getCurrentDay]];
        }
        
        [self pulseCircle];
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            self.circle.frame = frame;
        }completion:^(BOOL finished) {
            if (finished) {
                self.circle.alpha = 0.0f;
                self.circle.frame = frameFinal;
                [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
                    self.circle.center = self.labelSun.center;
                    self.circle.alpha = 1.0f;
                }completion:^(BOOL finished) {
                    if (finished) {
                        [UIView animateWithDuration:0.25f animations:^{
                            [self changeColors];
                            [self pulseCircle];
                        }];
                    }
                }];
            }
        }];
    }else {
        [self moveBallToDay:currentDay animated:YES];
    }
    
}

@end
