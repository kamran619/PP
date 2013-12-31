//
//  PCFAutoCompleteTextField.h
// 
//
//  Created by Kamran Pirwani on 6/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCObject.h"

typedef enum {
    AUTOCOMPLETE_DIRECTION_TOP = 0,
    AUTOCOMPLETE_DIRECTION_BOTTOM
} AutoCompleteDirection;

@protocol PCFAutoCompleteTextFieldDelegate <NSObject>
-(void)textFieldDidEndEditing:(UITextField *)textField;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;
-(void)textFieldDidBeginEditing:(UITextField *)textField;

@end

//This is a subclass of a UIView..It implements the required delegates for the UITextView and UITableView
@interface PCFAutoCompleteTextField : UIView <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id<PCFAutoCompleteTextFieldDelegate> delegate;
@property (nonatomic, strong) UITextField *textField;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataToAutoComplete;
@property(nonatomic, strong) NSMutableArray *matchingData;
@property (nonatomic) BOOL useKey;
@property (nonatomic) BOOL displayingAutoSuggest;
@property (nonatomic, strong) PCCObject *selectedObject;
//This is the designated initializer. Pass in the frame of the UITextField you want, and the direction you want it to AutoComplete. Currently only the bottom direction is supported
- (id)initWithFrame:(CGRect)frame direction:(AutoCompleteDirection)direction;

//Customize the UITextField and UITableView as well as set delegates
//override for further customization
-(void)customizeViews;

//Required: Set the data source used to check for autocompletion
-(void)setAutoCompleteDataSource:(NSMutableArray *)array;

//The maximum number of rows that will be shown in the autocomplete tableview
-(void)setMaximumNumberofRowsShownAtOnce:(NSInteger)number;

//Main login is performed here. Check to see which strings match and update tableview
-(void)updateAutoCompletion:(NSString *)substring;

//Calculate the height of the tableview according to the number of rows we want visible 
-(float)getHeightForNumberOfRowsShown;

//animate tableview in and out
-(void)animateTableViewOut:(BOOL)resignTextField;
-(void)animateTableViewIn;

@end
