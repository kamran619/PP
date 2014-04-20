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

#import "UIView+Animations.h"

#import "PCFNetworkManager.h"
#import "PCCTermViewController.h"

@interface PCCScheduleViewController ()

@end

#define CUSTOM_COLOR [UIColor colorWithRed:.89411f green:.8980f blue:.97254f alpha:1.0f]
enum CellType
{
    CellTypeNormal = 0,
    CellTypeFlipped = 1
} typedef CellType;


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
    isLoading = YES;
    animationDirection = AnimationDirectionLeft;
    [self initRefreshView];
    [self initHeader];
    [self loadSchedule];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    //force load view
    [headerViewController view];
    headerViewController.delegate = self;
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:headerViewController action:@selector(leftArrowPushed:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:headerViewController action:@selector(rightArrowPushed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];
    
}

-(void)fetchSchedule
{
        isLoading = YES;
        scheduleArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:preferredSchedule.value];
        if (scheduleArray != nil) {
            self.termButton.title = preferredSchedule.key;
            dayArray = [self generateDayArray];
            //reload tableview data
            isLoading = NO;
            //[self.tableView reloadData];
        }else {
            self.termButton.title = preferredSchedule.key;
            dayArray = nil;
            isLoading = YES;
            [self.activityIndicator startAnimating];
            [self.tableView reloadData];
        }

    
    [self immediatelyFetchSchedule];
}

-(void)immediatelyFetchSchedule
{
    dispatch_queue_t task = dispatch_queue_create("Login to myPurdue", nil);
    dispatch_async(task, ^{
        NSDictionary *credentials = [Helpers getCredentials];
        NSString *username, *password;
        username = [credentials objectForKey:kUsername];
        password = [credentials objectForKey:kPassword];
        NSDictionary *dictionary;
        if ([[MyPurdueManager sharedInstance] loginWithUsername:username andPassword:password] == NO) {
            NSLog(@"The login failed");
        }else {
            scheduleArray = [[MyPurdueManager sharedInstance] getCurrentScheduleViaDetailSchedule];
            PCCObject *term = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow];
            preferredSchedule.key = term.key;
            preferredSchedule.value = term.value;
            
            NSMutableArray *tempArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:term.value];
            NSMutableArray *classesToAdd, *classesToRemove;
            classesToAdd = [NSMutableArray array], classesToRemove = [NSMutableArray array];
            if (tempArray && ![tempArray isEqualToArray:scheduleArray]) {
                for (PCFClassModel *class in scheduleArray) {
                    if (![tempArray containsObject:class]) {
                        [classesToAdd addObject:class.CRN];
                    }
                }

                for (PCFClassModel *class in tempArray) {
                    if (![scheduleArray containsObject:class]) {
                        [classesToRemove addObject:class.CRN];
                    }
                }
                
                dictionary = @{@"add": classesToAdd, @"remove": classesToRemove};
            }else {
                //temp array is full
                if (!tempArray) {
                    NSMutableArray *schedule = [NSMutableArray arrayWithCapacity:3];
                    for (PCFClassModel *class in scheduleArray) {
                        if (![tempArray containsObject:class]) {
                            [schedule addObject:class.CRN];
                        }
                    }
                    
                    dictionary = @{@"add": schedule};
                }
            }
                
                [[PCCDataManager sharedInstance] setObject:scheduleArray ForKey:term.value InDictionary:DataDictionarySchedule];
                [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandSendSchedule withDictionary:dictionary];
            }
            //reload data
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doneLoadingTableViewData];
            });
    });

}
- (void)loadSchedule
{
    PCCObject *preferredScheduleToShow = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionaryUser WithKey:kPreferredScheduleToShow];
    if (!preferredScheduleToShow) {
        [self choosepreferredScheduleValue:nil];
    }else {
        preferredSchedule = [[PCCObject alloc] initWithKey:preferredScheduleToShow.key AndValue:preferredScheduleToShow.value];
        self.termButton.title = preferredSchedule.key;
        //
        [Helpers asyncronousBlockWithName:@"Retreive Terms" AndBlock:^{
            NSMutableArray *tempTerms = [MyPurdueManager getMinimalTerms].mutableCopy;
            if ([tempTerms count] != [[[PCCDataManager sharedInstance] arrayTerms] count]) [[PCCDataManager sharedInstance] setArrayTerms:tempTerms];
        }];
        //
        scheduleArray = [[PCCDataManager sharedInstance] getObjectFromDictionary:DataDictionarySchedule WithKey:preferredSchedule.value];
        if (scheduleArray == nil) {
            [self fetchSchedule];
        }else {
            //reload tableview data
            isLoading = NO;
            dayArray = [self generateDayArray];
            //reload data
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doneLoadingTableViewData];
            });
        }
    }
}

#pragma mark PCCTerm Delegate
-(void)termPressed:(PCCObject *)term
{
    preferredSchedule = [[PCCObject alloc] initWithKey:term.key AndValue:term.value];
    [[PCCDataManager sharedInstance] setObject:preferredSchedule ForKey:kPreferredScheduleToShow InDictionary:DataDictionaryUser];
    self.termButton.title = preferredSchedule.key;
    animationDirection = AnimationDirectionUp;
    [self performSelectorOnMainThread:@selector(fetchSchedule) withObject:nil waitUntilDone:NO];
    
}

- (IBAction)choosepreferredScheduleValue:(id)sender
{
    if (!self.termVC) {
        self.termVC = (UINavigationController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCTerm"];
        PCCTermViewController *vc = self.termVC.childViewControllers.lastObject;
        [vc setType:PCCTermTypeSchedule];
        [vc setDataSource:[PCCDataManager sharedInstance].arrayTerms];
        vc.delgate = self;
    }
    
    [self presentViewController:self.termVC animated:YES completion:nil];
}

-(NSArray *)generateDayArray
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:3];
    currentDay = [headerViewController getCurrentDay];
    for (PCFClassModel *class in scheduleArray) {
        if ([class.days rangeOfString:currentDay options:NSCaseInsensitiveSearch range:NSMakeRange(0, class.days.length)].location != NSNotFound) {
            NSArray *dates = [Helpers splitDate:class.dateRange];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM d, y"];
            if (dates) {
                NSString *dateOneStr = [dates objectAtIndex:0];
                NSString *dateTwoStr = [dates objectAtIndex:1];
                NSDate *dateOne = [dateFormatter dateFromString:dateOneStr];
                NSDate *dateTwo = [dateFormatter dateFromString:dateTwoStr];
                if ([Helpers isDate:[NSDate date] inRangeFirstDate:dateOne lastDate:dateTwo]) [array addObject:class];
            }
        }
    }
    
    return [Helpers sortArrayUsingTime:array];
}


-(void)didClickCell:(UILongPressGestureRecognizer *)gesture
{
    PCCScheduleCell *cell = (PCCScheduleCell *)[gesture view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (cell.tag == CellTypeNormal) {
            //Flip it
            [cell.frontView setAlpha:0.0f];
            [cell.backView setAlpha:1.0f];
            [UIView transitionWithView:cell duration:0.5f options:UIViewAnimationOptionTransitionCurlUp animations:^{
                
                
            }completion:^(BOOL finished ){
                if (finished) {
                    cell.tag = CellTypeFlipped;
                }
            }];
        }else if (cell.tag == CellTypeFlipped) {
            //Normalize it
            [cell.backView setAlpha:0.0f];
            [cell.frontView setAlpha:1.0f];
            [UIView transitionWithView:cell duration:0.5f options:UIViewAnimationOptionTransitionCurlDown animations:^{
                
                
            }completion:^(BOOL finished ){
                if (finished) {
                    cell.tag = CellTypeNormal;
                }
            }];
        }
    }
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
    
    if (animationDirection == AnimationDirectionLeft || animationDirection == AnimationDirectionRight) {
        rotation = CATransform3DMakeRotation((25.0*M_PI)/180, 0.0, 1.0f, 0.0f);
        rotation.m34 = 1.0/ -600;
    }else {
        //rotation = CATransform3DMakeRotation((90.0*M_PI)/180, 0.0, 0.7, 0.4);
        rotation = CATransform3DMakeRotation((25.0*M_PI)/180, 0.0, 1.0f, 0.0f);
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
    if (scheduleArray.count == 0 && isLoading == YES) {
        PCCEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kEmptyCell"];
        [cell.cellLabel setText:@""];
        return cell;
    }else if (scheduleArray.count == 0 && isLoading == NO) {
        PCCEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kEmptyCell"];
        [cell.cellLabel setText:@"No classes are being taken for this term."];
        return cell;
    }
    else if (dayArray.count == 0) {
        PCCEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kEmptyCell"];
        [cell.cellLabel setText:@"No classes held today :)"];
        return cell;
    }
    
    PCFClassModel *obj = [dayArray objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"kScheduleCell";
    PCCScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //put cell in default state
    cell.tag = CellTypeNormal;
    cell.frontView.alpha = 1.0f;
    cell.backView.alpha = 0.0f;
    
    NSArray *timeArray = [Helpers splitTime:obj.time];
    if (timeArray) {
        [[cell startTime] setText:[timeArray objectAtIndex:0]];
        [[cell endTime] setText:[timeArray objectAtIndex:1]];
    }

    cell.backgroundView = nil;
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }else {
        cell.contentView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    [[cell location] setText:obj.classLocation];
    [[cell courseName] setText:obj.courseNumber];
    [[cell courseTitle] setText:obj.classTitle];
    [[cell courseType] setText:obj.scheduleType];
    [[cell crn] setText:obj.CRN];
    [[cell courseSection] setText:obj.sectionNum];
    [[cell professor] setTitle:obj.instructor forState:UIControlStateNormal];
    
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didClickCell:)];
    [longGesture setDelegate:self];
    [cell addGestureRecognizer:longGesture];
    
    return cell;
    
}

#pragma mark UIGestureRecognizer Delegate
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
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
    if ([day intValue]) currentDay = day;
    dayArray = [self generateDayArray];
    [self.tableView reloadData];
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
    [self.tableView reloadData];
	
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
