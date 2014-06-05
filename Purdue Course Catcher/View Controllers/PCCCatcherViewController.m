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
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
        if (slots.enrolled > 0) {
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

#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
    numberFetched = 0;
    isLoading = YES;
    self.dataSource = [[PCCDataManager sharedInstance] arrayBasket];
	[self.tableView reloadData];
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
