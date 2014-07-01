//
//  PCCCatcherViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/2/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCCatcherViewController.h"
#import "PCCCatcherCell.h"
#import "PCFClassModel.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCCourseSlots.h"
#import "PCCDataManager.h"
#import "UIView+Animations.h"
#import "PCCHUDManager.h"
#import "PCCSearchResultsViewController.h"
@interface PCCCatcherViewController ()

@end

@implementation PCCCatcherViewController
{
    BOOL isLoading;
    EGORefreshTableHeaderView *refreshView;
    int numberFetched;
    NSArray *courses;
    PCFClassModel *courseToDelete;
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
    [self initRefreshView];
    isLoading = YES;
    numberFetched = 0;
    self.infoLabel.frame = CGRectMake(0, self.view.frame.size.height/2-self.tabBarController.tabBar.frame.size.height, 320.0f, 106.0f);
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UITabBarController *controller = (UITabBarController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    UITabBarItem *item = [[[controller tabBar] items] objectAtIndex:3];
    [item setBadgeValue:nil];
    [self reloadTableViewDataSource];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)registerPressed:(UIButton *)sender
{
    PCFClassModel *class = [self.dataSource objectAtIndex:sender.tag];
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        courses = [MyPurdueManager getCoursesForTerm:class.term WithCRN:class.CRN];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PCCHUDManager sharedInstance] dismissHUD];
            [self performSegueWithIdentifier:@"SearchResultsSegue" sender:self];
        });
    });
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchResultsSegue"]) {
        UINavigationController *controller = segue.destinationViewController;
        PCCSearchResultsViewController *vc = [controller.childViewControllers lastObject];
        vc.dataSource = courses;
        vc.searchType = (int) searchCRN;
    }
}
#pragma mark UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"kCatcherCell";
    PCCCatcherCell *cell = (PCCCatcherCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
    [cell.courseNumber setText:class.courseNumber];
    [cell.registerButton addTarget:self action:@selector(registerPressed:) forControlEvents:UIControlEventTouchUpInside];
    cell.registerButton.tag = indexPath.row;
    [cell.courseTitle setText:class.classTitle];
    [cell.scheduleType setText:class.scheduleType];
    [cell.CRN setText:class.CRN];
    [cell.activityIndicator startAnimating];
    cell.registerButton.alpha = 0.0f;
    cell.slots.alpha = 0.0f;
    [Helpers asyncronousBlockWithName:@"Get Slots" AndBlock:^{
    PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
    __block PCCCourseSlots *slots = [MyPurdueManager getCourseAvailabilityWithLink:class.classLink];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.activityIndicator stopAnimating];
        if ([slots.enrolled intValue] > 0) {
            [cell.slots fadeOut];
            [cell.registerButton fadeIn];
        }else {
            [cell.registerButton fadeOut];
            [cell.slots fadeIn];
            [cell.slots setText:[NSString stringWithFormat:@"SLOTS: %@/%@", slots.enrolled, slots.capacity]];
            
        }
        
        if (++numberFetched == self.dataSource.count) {
            isLoading = NO;
            [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5f];
       }
    });
}];

    return cell;

}

#pragma mark UITableView Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PCFClassModel *course = [self.dataSource objectAtIndex:indexPath.row];
        NSArray *keys = [NSArray arrayWithObjects:@"crn" , @"term",  nil];
        NSArray *objects = [NSArray arrayWithObjects:course.CRN, course.term, nil];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        [[PCFNetworkManager sharedInstance] setDelegate:self];
        courseToDelete = course;
        [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandUnCatch withDictionary:dictionary];
    }
}

#pragma mark - PCFNetworkDelegate
-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success
{
    ServerCommand command;
    if (success) {
        command = [[responseDictionary objectForKey:@"command"] intValue];
    }else {
        command = [[requestDictionary objectForKey:@"command"] intValue];
    }
    
    switch (command) {
        case ServerCommandUnCatch:
            if (success) {
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Complete" success:YES];
                [[PCCDataManager sharedInstance].arrayBasket removeObject:courseToDelete];
            }else {
                [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Error" success:NO];
            }
            break;
            
        default:
            break;
    }
    
    if (success) {
        [[PCCDataManager sharedInstance] saveData];
        [self reloadTableViewDataSource];
    }
}

#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
    numberFetched = 0;
    isLoading = YES;
    self.dataSource = [[PCCDataManager sharedInstance] arrayBasket];
    
    if (!self.dataSource || self.dataSource.count == 0) {
        [self.tableView fadeOut];
        self.infoLabel.transform = CGAffineTransformMakeScale(0.001, 0.001);
        self.infoLabel.alpha = 1.0f;
        [UIView animateWithDuration:0.35f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.infoLabel.transform = CGAffineTransformMakeScale(1, 1);
        }completion:nil];
    }else {
        [self.infoLabel fadeOut];
        [self.tableView fadeIn];
        [self.tableView reloadData];
    }
}

- (void)doneLoadingTableViewData{
    isLoading = NO;
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
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return isLoading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


@end
