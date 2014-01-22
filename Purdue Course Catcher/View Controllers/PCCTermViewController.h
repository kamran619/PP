//
//  PCCTermViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/18/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PCCObject;

enum PCCTermType
{
    PCCTermTypeSearch = 0,
    PCCTermTypeSchedule = 1,
    PCCTermTypeRegistration = 2,
    PCCTermTypeError = 3
} typedef PCCTermType;

@protocol PCCTermDelegate <NSObject>
-(void)termPressed:(PCCObject *)term;
@end

@interface PCCTermViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate>

@property (nonatomic, weak) id<PCCTermDelegate> delgate;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) PCCTermType type;

-(IBAction)dismissButtonPressed:(id)sender;
@end
