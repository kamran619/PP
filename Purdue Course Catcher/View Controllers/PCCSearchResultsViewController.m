//
//  PCCSearchResultsViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "PCCSearchResultsViewController.h"
#import "PCCSearchResultsCell.h"
#import "PCFClassModel.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCCourseSlots.h"
#import "MHNatGeoViewControllerTransition.h"
#import "MNHatGeoUnwindSegue.h"

@interface PCCSearchResultsViewController ()

@end

@implementation PCCSearchResultsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate Methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"kSearchResultsCell";
    PCCSearchResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    PCFClassModel *obj = [self.dataSource objectAtIndex:indexPath.row];
    
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
    [[cell days] setText:obj.days];
    int credits = [obj.credits intValue];
    NSString *credit;
    if (credits !=1) {
        credit = @"credits";
    }else {
        credit = @"credit";
    }
    [[cell credits] setText:[NSString stringWithFormat:@"%d %@", credits, credit]];
    [[cell crn] setText:obj.CRN];
    [[cell professor] setText:obj.instructor];
    
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

    return cell;
}
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self dismissNatGeoViewController];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCSearchResultsCell *newCell = (PCCSearchResultsCell *)cell;
    [newCell.activityIndicator startAnimating];
    [newCell.actionButton setAlpha:0.0f];
    [newCell.slots setAlpha:0.0f];
    [Helpers asyncronousBlockWithName:@"Get Slots" AndBlock:^{
        PCFClassModel *class = [self.dataSource objectAtIndex:indexPath.row];
        __block PCCCourseSlots *slots = [MyPurdueManager getCourseAvailabilityWithLink:class.classLink];
        dispatch_async(dispatch_get_main_queue(), ^{
            [newCell.activityIndicator stopAnimating];
            [newCell.slots setText:[NSString stringWithFormat:@"SLOTS: %@/%@", slots.enrolled, slots.capacity]];
            if (slots.enrolled.intValue <= 0) {
                //no slots left
                [newCell performSelector:@selector(setupCatcher) withObject:nil afterDelay:1.0f];
            }else {
                [newCell performSelector:@selector(setupRegister) withObject:nil afterDelay:1.0f];
            }
        });
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

@end
