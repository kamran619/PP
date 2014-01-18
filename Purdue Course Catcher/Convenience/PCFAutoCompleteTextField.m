//
//  PCFAutoCompleteTextField.m
//  
//
//  Created by Kamran Pirwani on 6/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCFAutoCompleteTextField.h"
#import "PCCObject.h"
#import "PCCSearchViewController.h"
#import <QuartzCore/QuartzCore.h>

#define INITIAL_ARRAY_SIZE 10 
#define DEFAULT_ROW_HEIGHT 44

#define TABLEVIEW_SLIDE_ANIMATION_DURATION 0.2f

@implementation PCFAutoCompleteTextField
{
    NSInteger maximumRowsShownAtOnce;
    BOOL selectedCell;
    
}

#pragma mark initializers

-(id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame direction:AUTOCOMPLETE_DIRECTION_BOTTOM];
}

-(void)setMatchingData:(NSMutableArray *)matchingData
{
    if (matchingData == nil) {
        NSAssert(false, @"Must provide valid data to check against for matches.");
    }
    _matchingData = matchingData;
}
- (id)initWithFrame:(CGRect)frame direction:(AutoCompleteDirection)direction
{
    NSAssert(frame.size.height >= 30, @"The size of the textfield must be at least 30");
    
    if (self = [super initWithFrame:frame]) {
        //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        //create textfield
        self.textField = [[UITextField alloc] initWithFrame:self.bounds];
        self.selectedObject = [[PCCObject alloc] initWithKey:@"" AndValue:@""];
        selectedCell = NO;
        self.displayingAutoSuggest = NO;
        //set default value
        [self setMaximumNumberofRowsShownAtOnce:3];
        
        //get frame for where tableview will sit
        CGRect autoCompleteFrame = [self getTableViewFrame:self.bounds direction:direction];
        self.tableView = [[UITableView alloc] initWithFrame:autoCompleteFrame style:UITableViewStylePlain];
        
        [self customizeViews];
        
        //set delegate/data source
        self.textField.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self setBackgroundColor:[UIColor lightGrayColor]];
        [self.tableView setAllowsSelection:YES];
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frame.size.height + autoCompleteFrame.size.height)];
        [self setBackgroundColor:[UIColor clearColor]];
        //add views as subviews
        [self addSubview:self.tableView];
        [self addSubview:self.textField];
        
        //initialize the array that holds matches
        self.matchingData = [[NSMutableArray alloc] initWithCapacity:INITIAL_ARRAY_SIZE];
    }
    
    return self;
}

#pragma mark Class Setup
//override for UITextView/UITableView customization
-(void)customizeViews
{
    [self.textField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    //[self.textField setBackground:[UIImage imageNamed:@"1slot2.png"]];
    //[self.textField setTextColor:[UIColor darkGrayColor]];
    //hide tableview until the user types
    [self.tableView setHidden:YES];
    //need to remove bgview to see underlying color
    [self.tableView setBackgroundView:nil];
    UIColor *customColor = [UIColor colorWithWhite:1.0f alpha:0.6f];
    [self.tableView setBackgroundColor:customColor];
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView.layer setCornerRadius:6.0f];
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
}

-(void)setMaximumNumberofRowsShownAtOnce:(NSInteger)number
{
    NSAssert(number > 0, @"The maximum number of rows must be bigger than 0");
    maximumRowsShownAtOnce = number;
    
}

//return tableview frame based on where the autocompletion is coming from(top or bottom)
-(CGRect)getTableViewFrame:(CGRect)textViewFrame direction:(AutoCompleteDirection)direction
{
    CGRect newFrame = textViewFrame;
    if (direction == AUTOCOMPLETE_DIRECTION_TOP) {
        NSAssert(false, @"Currently not supported");
    }else if(direction == AUTOCOMPLETE_DIRECTION_BOTTOM) {
        newFrame.origin.y += newFrame.size.height - 4;
        newFrame.size.height = [self getHeightForNumberOfRowsShown];
    }else {
        NSAssert(false, @"AutoCompleteDirection can only be AUTOCOMPLETE_DIRECTION_TOP or AUTOCOMPLETE_DIRECTION_BOTTOM");
    }
    return newFrame;
}

//set the data source used for autocompletion
//This is your array of values you want to autocomplete for
-(void)setAutoCompleteDataSource:(NSMutableArray *)autoCompleteDataSource
{
    self.dataToAutoComplete = autoCompleteDataSource;
}

//return a height for the tableview corresponding to the max number of rows visible you set
-(float)getHeightForNumberOfRowsShown
{
    float height;
    int rowHeight = (self.tableView.rowHeight == 0) ? DEFAULT_ROW_HEIGHT : self.tableView.rowHeight;
    if (self.matchingData.count > 0 && self.matchingData.count < maximumRowsShownAtOnce) {
        height = rowHeight * self.matchingData.count;
    }else {
        height = rowHeight * maximumRowsShownAtOnce;
    }
     
    return height;
}

#pragma mark TableView Animations

-(void)animateTableViewIn
{
    self.displayingAutoSuggest = YES;
    [self.tableView reloadData];
    float height = [self getHeightForNumberOfRowsShown];
    self.tableView.hidden = NO;
    [UIView animateWithDuration:TABLEVIEW_SLIDE_ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
         self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);
    }completion:^(BOOL finished) {
        if (self.matchingData.count > maximumRowsShownAtOnce) [self.tableView flashScrollIndicators];
    }];
}

-(void)animateTableViewOut:(BOOL)resignTextField
{
    self.displayingAutoSuggest = NO;
    float height = 0;
    [UIView animateWithDuration:TABLEVIEW_SLIDE_ANIMATION_DURATION delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, height);
    }completion:^(BOOL finished) {
        if (finished) {
            //self.matchingData = nil;
            self.tableView.hidden = YES;
            if (resignTextField) [self.textField resignFirstResponder];
        }
    }];
}

#pragma mark AutoCompletion Logic

-(void)updateAutoCompletion:(NSString *)substring
{
    if (substring.length > 0) {
        BOOL match = NO;
        [self.matchingData removeAllObjects];
        for (PCCObject *object in self.dataToAutoComplete) {
            NSString *check;
            if (self.useKey) {
                check = object.key;
            }else {
                check = object.value;
            }
            NSRange range = [check rangeOfString:substring options:NSCaseInsensitiveSearch];
            if (range.location != NSNotFound) {
                //if (![self.matchingData containsObject:string])
                [self.matchingData addObject:object];
                match = YES;
            }
        }
        //reload the tableview and animate
        if (match)  {
            [self animateTableViewIn];
        }else {
            [self animateTableViewOut:NO];
        }
        
    }
}

#pragma mark UITableViewDelegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    if ([ver floatValue] < 6) {
        //running below iOS 6
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        //Must check if cell is null and instantiate in ios5 and below
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
    }else {
        //running iOS 6 or above
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    if (self.dataToAutoComplete.count == 1) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    PCCObject *object = [self.matchingData objectAtIndex:indexPath.row];
    if (self.useKey) {
        [cell.textLabel setText:object.key];
    }else {
        [cell.textLabel setText:object.value];
    }
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:10]];
    [cell setBackgroundView:nil];
    UIColor *customColor = [UIColor colorWithWhite:.9f alpha:0.8f];
    [cell setBackgroundColor:customColor];
    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
    cell.userInteractionEnabled = YES;
    return cell;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    if (CGRectContainsPoint(self.textField.frame, point)) {
        return YES;
    }else if (CGRectContainsPoint(self.tableView.frame, point) && self.displayingAutoSuggest == YES) {
        return YES;
    }
    
    return NO;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.matchingData && self.matchingData.count > 0) return 1;
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchingData.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.matchingData,  @"The data source is nil when we are trying to assign a value from it");
    PCCObject *object = [self.matchingData objectAtIndex:indexPath.row];
    if (self.useKey) {
        [self.textField setText:object.key];
    }else {
        [self.textField setText:object.value];
    }
    self.selectedObject.key = object.key;
    self.selectedObject.value = object.value;
    selectedCell = YES;
    [self animateTableViewOut:YES];
}

#pragma mark UITextFieldDelegate Methods


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *substring = [NSString stringWithString:self.textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    if ([substring isEqualToString:@""]) {
        [self animateTableViewOut:NO];
    }else {
        [self updateAutoCompletion:substring];
    }
    
    return YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate textFieldDidBeginEditing:(UITextField *)self];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self.delegate textFieldShouldReturn:self.textField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTableViewOut:YES];
    if (!selectedCell) {
        [self validateInput];
    }
    [self.delegate textFieldDidEndEditing:(UITextField *)self];
}

-(void)validateInput
{
    selectedCell = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *key = self.textField.text;
        SEL s;
        if (self.useKey) {
            s = @selector(key);
        }else {
            s = @selector(value);
        }
        for (PCCObject *obj in self.matchingData) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            if ([[obj performSelector:s withObject:nil] isEqualToString:key]) {
#pragma clang diagnostic pop
                self.selectedObject.key = obj.key;
                self.selectedObject.value = obj.value;
            }
        }
    });
}
@end
