//
//  PCCTermViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/18/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PCCObject;

@protocol PCCTermProtocol <NSObject>
-(void)termPressed:(PCCObject *)term;
@end

@interface PCCTermViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id<PCCTermProtocol> delgate;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
