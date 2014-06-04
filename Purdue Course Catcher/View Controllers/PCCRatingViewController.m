//
//  PCCRatingViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 4/4/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRatingViewController.h"
#import "PCFNetworkManager.h"
#import "PCCRating.h"
#import "PCCProfessorRating.h"
#import "PCCCourseRating.h"
#import "PCCCourseRatingsCell.h"
#import "PCCProfessorRatingsCell.h"
#import "Helpers.h"

@interface PCCRatingViewController ()

@end

@implementation PCCRatingViewController

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
    [self refreshWithServer];
}

-(void)refreshWithServer
{
    [self.activityIndicator startAnimating];
    [[PCFNetworkManager sharedInstance] setDelegate:self];
    [[PCFNetworkManager sharedInstance] prepareDataForCommand:ServerCommandViewRatings withDictionary:nil];
}

-(void)responseFromServer:(NSDictionary *)responseDictionary initialRequest:(NSDictionary *)requestDictionary wasSuccessful:(BOOL)success
{
    //view ratings
    NSError *error;
    NSData *data = [[responseDictionary objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        [self.activityIndicator stopAnimating];
        return;
    }
    
    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
    
    
    for (NSString *key in jsonResponse.allKeys) {
        NSArray *array = [jsonResponse objectForKey:key];
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:array.count];
        for (NSString *str in array) {
            NSData *myData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:myData options:NSJSONReadingAllowFragments error:&error];
            NSNumber *ratingType = response[@"ratingType"];
            if (ratingType.intValue == RatingTypeProfessor) {
                //professor review
                NSNumber *ratings = response[@"rating"];
                NSNumber *numberOfRatings = response[@"numberOfRatings"];
                PCCProfessorRating *professorRating = [[PCCProfessorRating alloc] initWithName:response[@"name"] rating:ratings.intValue numberOfRatings:numberOfRatings.intValue];
                [newArray addObject:professorRating];
                
            }else {
                //course review
                NSNumber *courseNumber = response[@"courseNumber"];
                NSNumber *ratings = response[@"rating"];
                NSNumber *numberOfRatings = response[@"numberOfRatings"];
                
                PCCCourseRating *courseRating = [[PCCCourseRating alloc] initWithSubject:response[@"subject"] courseNumber:courseNumber.intValue rating:ratings.intValue numberOfRatings:numberOfRatings.intValue title:response[@"title"]];
                [newArray addObject:courseRating];
            }
        }
        [jsonResponse setObject:newArray forKey:key];
    }
    
    //the data has been initialized
    self.dataSource = jsonResponse.copy;
    [self.activityIndicator stopAnimating];
    [UIView animateWithDuration:0.25f animations:^{
        self.tableView.alpha = 1.0f;
    }completion:^(BOOL finished) {
        if (finished) [self performSelectorOnMainThread:@selector(reloadTableView) withObject:nil waitUntilDone:NO];
    }];
}

-(void)reloadTableView
{
    [self.tableView reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array =  self.dataSource[[[self.dataSource allKeys] objectAtIndex:section]];
    return array.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array =  self.dataSource[[[self.dataSource allKeys] objectAtIndex:indexPath.section]];
    
    if ([[array lastObject] isKindOfClass:[PCCCourseRating class]]) {
        //it is a course rating type
        NSString *identifier = @"kCourseRatingCell";
        PCCCourseRatingsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        PCCCourseRating *rating = [array objectAtIndex:indexPath.row];
        cell.masterText.text = [NSString stringWithFormat:@"%@ %d", rating.subject, rating.courseNumber];
        cell.detailText.text = rating.title;
        cell.stars.image = [Helpers getImageForStars:rating.rating];
        cell.numberOfReviews.text = (rating.numberOfRatings == 0) ? @"0 reviews" : [NSString stringWithFormat:@"%d reviews", rating.numberOfRatings];
        if (rating.numberOfRatings == 1) cell.numberOfReviews.text = [cell.numberOfReviews.text substringToIndex:cell.numberOfReviews.text.length-1];
        return cell;
    }else {
        //it is a professor rating type
        NSString *identifier = @"kProfessorRatingCell";
        PCCProfessorRatingsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        PCCProfessorRating *rating = [array objectAtIndex:indexPath.row];
        cell.masterText.text = rating.name;
        cell.stars.image = [Helpers getImageForStars:rating.rating];
        cell.numberOfReviews.text = (rating.numberOfRatings == 0) ? @"0 reviews" : [NSString stringWithFormat:@"%d reviews", rating.numberOfRatings];
        if (rating.numberOfRatings == 1) cell.numberOfReviews.text = [cell.numberOfReviews.text substringToIndex:cell.numberOfReviews.text.length-1];
        return cell;
    }
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataSource.allKeys objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array =  self.dataSource[[[self.dataSource allKeys] objectAtIndex:indexPath.section]];
    if ([[array lastObject] isKindOfClass:[PCCCourseRating class]]) return 61;
    if ([[array lastObject] isKindOfClass:[PCCProfessorRating class]])  return 49;
    return tableView.rowHeight;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[PCCCourseRatingsCell class] forCellReuseIdentifier:@"kCourseRatingCell"];
    [tableView registerClass:[PCCProfessorRatingsCell class] forCellReuseIdentifier:@"kProfessorRatingCell"];
}




@end
