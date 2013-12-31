//
//  PCCScheduleViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCScheduleViewController.h"
#import "PCCDataManager.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "PCCObject.h"
#import "PCFClassModel.h"

#import "PCCScheduleCell.h"
#import "PCCEmptyCell.h"

#import "PCCScheduleHeaderViewController.h"

#import "Helpers.h"

#import "EGORefreshTableHeaderView.h"

@interface PCCScheduleViewController ()

@end

#define CUSTOM_COLOR [UIColor colorWithRed:.89411f green:.8980f blue:.97254f alpha:1.0f]
enum AnimationDirection
{
    AnimationDirectionLeft = 0,
    AnimationDirectionRight = 1,
    AnimationDirectionUp = 2
    
}typedef AnimationDirection;

@implementation PCCScheduleViewController
{
    PCCObject *preferredSchedule;
    NSArray *scheduleArray;
    NSArray *dayArray;
    PCCScheduleHeaderViewController *headerViewController;
    NSString *currentDay;
    BOOL isLoading;
    EGORefreshTableHeaderView *refreshView;
    AnimationDirection animationDirection;
    
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
    isLoading = NO;
    animationDirection = AnimationDirectionUp;
    [self initRefreshView];
    [self initHeader];
    [self loadSchedule];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [headerViewController springHeader];
}
- (void)initRefreshView
{
    if (refreshView == nil) {
		
		refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		refreshView.delegate = self;
		[self.tableView addSubview:refreshView];
	}
	
	//  update the last update date
	[refreshView refreshLastUpdatedDate];
}

-(void)initHeader
{
    if (headerViewController) return;
    headerViewController = [[PCCScheduleHeaderViewController alloc] initWithNibName:@"PCCScheduleHeaderViewController" bundle:[NSBundle mainBundle]];
    [headerViewController view];
    headerViewController.delegate = self;
}

-(void)fetchSchedule
{
    isLoading = YES;
        scheduleArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:preferredSchedule.value];
        if (scheduleArray != nil) {
            self.containerViewForSchedule.hidden = NO;
            [headerViewController.headerTitle setText:preferredSchedule.key];
            dayArray = [self generateDayArray];
            //reload tableview data
            isLoading = NO;
            [self.tableView reloadData];
        }else {
            [headerViewController.headerTitle setText:preferredSchedule.key];
            self.containerViewForSchedule.hidden = NO;
            dayArray = nil;
            [self.tableView reloadData];
            isLoading = YES;
            [self.activityIndicator startAnimating];
        }

    
    [self immediatelyFetchSchedule];
}

-(void)immediatelyFetchSchedule
{
    dispatch_queue_t task = dispatch_queue_create("Login to myPurdue", nil);
    dispatch_async(task, ^{
        if ([[MyPurdueManager sharedInstance] loginWithUsername:@"kpirwani" andPassword:@"!ScirockS619"] == NO) {
            NSLog(@"The login failed");
        }else {
            scheduleArray = [[MyPurdueManager sharedInstance] getCurrentScheduleViaDetailSchedule];
            [[PCCDataManager sharedInstance] setObject:scheduleArray ForKey:preferredSchedule.value InDictionary:DataDictionarySchedule];
            //reload data
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doneLoadingTableViewData];
            });
        }
    });

}
- (void)loadSchedule
{
    PCCObject *preferredScheduleToShow = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow];
    if (!preferredScheduleToShow) {
        if (![PCCDataManager sharedInstance].arrayTerms) {
            //terms have never been aggregated
            [self.setupContainerView setHidden:YES];
            [self.containerViewForSchedule setHidden:YES];
            [self.activityIndicator startAnimating];
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                [[PCCDataManager sharedInstance] setArrayTerms:[MyPurdueManager getMinimalTerms].mutableCopy];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                    [self.setupContainerView setHidden:NO];
                    [self.pickerView reloadAllComponents];
                    preferredSchedule = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
                });
            }];
        }else {
            [self.setupContainerView setHidden:NO];
            [self.containerViewForSchedule setHidden:YES];
            [self.pickerView reloadAllComponents];
            preferredSchedule =  [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:0];
            //we have terms..lets show them, and still make a network call
            [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
                NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
                if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pickerView reloadAllComponents];
                });
            }];
            
        }
    }else {
        //setup view
        self.setupContainerView.center = CGPointMake(320, 21);
        self.setupContainerView.hidden = YES;
        self.containerViewForSchedule.hidden = YES;
        [self addBarButtonItem];
        //we have terms..lets show them, and still make a network call
        [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
            NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
            if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickerView reloadAllComponents];
            });
        }];
        //we have the preferred schedule term saved..
        preferredSchedule = preferredScheduleToShow;
        
        scheduleArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:preferredSchedule.value];
        if (scheduleArray == nil) {
            [self fetchSchedule];
        }else {
            self.containerViewForSchedule.hidden = NO;
            //reload tableview data
            headerViewController.headerTitle.text = preferredSchedule.key;
            dayArray = [self generateDayArray];
            [self.tableView reloadData];
        }
    }
}

-(void)addBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(choosepreferredScheduleValue:)];
    [self.navItem setRightBarButtonItem:item animated:YES];
}

- (IBAction)choosepreferredScheduleValue:(id)sender
{
    [UIView animateWithDuration:0.25f animations:^{
        CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, 1, 0.001);
        self.containerViewForSchedule.transform = t;
    }completion:^(BOOL finished) {
        if (finished) {
            self.containerViewForSchedule.hidden = YES;
            self.containerViewForSchedule.transform = CGAffineTransformIdentity;
            [self.setupContainerView setHidden:NO];
            self.setupContainerView.transform = CGAffineTransformMakeScale(0.001, 0.001);
            [UIView animateWithDuration:0.5f animations:^{
                self.setupContainerView.center = self.containerViewForSchedule.center;
                CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                self.setupContainerView.transform = t;
                [self.navItem setRightBarButtonItem:nil animated:YES];
            }];
        }
    }];
}

- (IBAction)proceedToSchedule:(id)sender
{
    [[PCCDataManager sharedInstance] setObject:preferredSchedule ForKey:kPreferredScheduleToShow InDictionary:DataDictionaryUser];
    [headerViewController.headerTitle setText:preferredSchedule.key];
    animationDirection = AnimationDirectionUp;
    [UIView animateWithDuration:0.25f animations:^{
        self.setupContainerView.center = CGPointMake(320, 21);
        CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, .001, 0.001);
        self.setupContainerView.transform = t;
    }completion:^(BOOL finished) {
        self.setupContainerView.transform = CGAffineTransformIdentity;
        self.setupContainerView.hidden = YES;
        self.containerViewForSchedule.hidden = NO;
        self.containerViewForSchedule.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, .001);
        [self addBarButtonItem];
        [UIView animateWithDuration:0.5f animations:^{
            CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
            self.containerViewForSchedule.transform = t;
        }completion:^(BOOL finished) {
            if (finished) {
                [self performSelectorOnMainThread:@selector(fetchSchedule) withObject:nil waitUntilDone:NO];
            }
        }];
    }];
}

-(NSArray *)generateDayArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    currentDay = [headerViewController getCurrentDay];
    for (PCFClassModel *class in scheduleArray) {
        if ([class.days rangeOfString:currentDay options:NSCaseInsensitiveSearch range:NSMakeRange(0, class.days.length)].location != NSNotFound) {
            [array addObject:class];
        }
    }
    
    return [self sortArrayUsingTime:array];
}

-(NSArray *)sortArrayUsingTime:(NSMutableArray *)array {
    return [array sortedArrayUsingComparator:^(id obj1, id obj2) {
        PCFClassModel *objectOne = (PCFClassModel *)obj1;
        PCFClassModel *objectTwo = (PCFClassModel *)obj2;
        NSArray *timeArrayOne = [Helpers splitTime:objectOne.time];
        NSArray *timeArrayTwo = [Helpers splitTime:objectTwo.time];
        
        NSInteger timeOneStart = [self getIntegerRepresentationOfTime:[timeArrayOne objectAtIndex:0]];
        NSInteger timeOneEnd = [self getIntegerRepresentationOfTime:[timeArrayOne objectAtIndex:1]];

        NSInteger timeTwoStart = [self getIntegerRepresentationOfTime:[timeArrayTwo objectAtIndex:0]];
        NSInteger timeTwoEnd = [self getIntegerRepresentationOfTime:[timeArrayTwo objectAtIndex:1]];
        
        if (timeOneStart < timeTwoStart) return (NSComparisonResult)NSOrderedAscending;
        if (timeOneStart > timeTwoStart) return (NSComparisonResult)NSOrderedDescending;
        
        //equal
            if (timeOneEnd < timeTwoEnd) {
                return NSOrderedAscending;
            }else if (timeOneEnd < timeTwoEnd) {
                return NSOrderedDescending;
            }else {
                return NSOrderedSame;
            }
    }];
}

-(NSInteger)getIntegerRepresentationOfTime:(NSString *)str {
    if ([str isEqualToString:@"TBA"]) return INFINITY;
    //str is 09:30 am
    NSScanner *scanner = [[NSScanner alloc] initWithString:str];
    NSString *firstStringNumber, *secondStringNumber, *thirdStringNumber;
    NSInteger firstNumber = 0, secondNumber = 0, thirdNumber = 0;
    [scanner scanUpToString:@":" intoString:&firstStringNumber];
    [scanner setScanLocation:([scanner scanLocation] + 1)];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&secondStringNumber];
    [scanner setScanLocation:([scanner scanLocation] + 1)];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&thirdStringNumber];
    firstNumber = [firstStringNumber integerValue];
    secondNumber = [secondStringNumber integerValue];
    if ([thirdStringNumber isEqualToString:@"AM"]) {
        //am
        thirdNumber = 0;
    }else {
        //pm
        thirdNumber = 720;
    }
    NSInteger intergerRepresentation = (firstNumber*60) + secondNumber + thirdNumber;
    return intergerRepresentation;
}
#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    preferredSchedule = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PCCObject *obj = [[[PCCDataManager sharedInstance] arrayTerms] objectAtIndex:row];
    
    return obj.key;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

#pragma mark UIPickerView Data Source
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[PCCDataManager sharedInstance] arrayTerms] count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


#pragma mark UITableView Delegate

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return headerViewController.view;
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return headerViewController.view.frame.size.height;
    return 0.0f;
}

//This function is where all the magic happens
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    
    if (animationDirection == AnimationDirectionUp) {
        rotation = CATransform3DMakeRotation((90.0*M_PI)/180, 0.0, 1.0, 0.0);
        rotation.m34 = 1.0/ -600;
    }else {
        rotation = CATransform3DMakeRotation((90.0*M_PI)/180, 0.0, 0.7, 0.4);
        rotation.m34 = 1.0/ -600;
    }
    
    
    //2. Define the initial state (Before the animation)
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    if (animationDirection == AnimationDirectionLeft) {
        cell.layer.anchorPoint = CGPointMake(0, 0.5);
    }else if (animationDirection == AnimationDirectionRight){
        cell.layer.anchorPoint = CGPointMake(1, 0.5);
    }else {
        cell.layer.anchorPoint = CGPointMake(0, 0);
    }
    
    
    //3. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.6];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (dayArray.count == 0) {
        PCCEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kEmptyCell"];
        [cell.cellLabel setText:@"No classes held today :)"];
        return cell;
    }
    
    PCFClassModel *obj = [dayArray objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"kScheduleCell";
    PCCScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSArray *timeArray = [Helpers splitTime:obj.time];
    if (timeArray) {
        [[cell startTime] setText:[timeArray objectAtIndex:0]];
        [[cell endTime] setText:[timeArray objectAtIndex:1]];
    }

    [[cell location] setText:obj.classLocation];
    [[cell courseName] setText:obj.courseNumber];
    [[cell courseTitle] setText:obj.classTitle];
    [[cell courseType] setText:obj.scheduleType];
    [[cell date] setText:obj.dateRange];
    [[cell courseSection] setText:obj.sectionNum];
    
    //Hilight date if it is in the range
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d, y"];
    
    NSArray *dates = [Helpers splitDate:obj.dateRange];
    if (dates) {
        NSString *dateOneStr = [dates objectAtIndex:0];
        NSString *dateTwoStr = [dates objectAtIndex:1];
        NSDate *dateOne = [dateFormatter dateFromString:dateOneStr];
        NSDate *dateTwo = [dateFormatter dateFromString:dateTwoStr];
        if ([Helpers isDate:[NSDate date] inRangeFirstDate:dateOne lastDate:dateTwo])
            [[cell date] setTextColor:[cell location].textColor];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = CUSTOM_COLOR;
        cell.alpha = 0.25;
         //228 229 248
    }else {
        cell.backgroundView.backgroundColor = [UIColor clearColor];
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    return cell;
    
}


#pragma mark UITableView Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isLoading) return 0;
    if (dayArray.count == 0) return 1;
    return dayArray.count;
}

#pragma mark PCCScheduleHeader Delegate
-(void)dayChangedTo:(NSString *)day
{
    if ([day intValue])
    currentDay = day;
    dayArray = [self generateDayArray];
    [self.tableView reloadData];
}

-(void)animationDirectionChangedTo:(int)direction
{
    animationDirection = AnimationDirectionUp;
}
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	isLoading = YES;
    [self immediatelyFetchSchedule];
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	isLoading = NO;
    [self.activityIndicator stopAnimating];
    dayArray = [self generateDayArray];
	[refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[refreshView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[refreshView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	//[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return isLoading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
