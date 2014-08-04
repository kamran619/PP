//
//  PCCAddRatingChooseSemesterViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCAddRatingChooseSemesterViewController.h"
#import "PCCObject.h"
#import "PCCHUDManager.h"
#import "Helpers.h"
#import "MyPurdueManager.h"
#import "PCCAddRatingChooseCourseViewController.h"
#import "PCCAddRatingChooseProfessorViewController.h"

@interface PCCAddRatingChooseSemesterViewController ()
{
    NSArray *_courses;
}
@end

@implementation PCCAddRatingChooseSemesterViewController

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kAddRatingSemesterCell"];
    PCCObject *term = self.dataSource[indexPath.row];
    cell.textLabel.text = term.key;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
    [[MyPurdueManager sharedInstance] loginWithSuccessBlock:^{
        [Helpers asyncronousBlockWithName:@"Retry Terms" AndBlock:^{
            _courses = [[MyPurdueManager sharedInstance] getCurrentScheduleViaDetailScheduleWithTerm:self.dataSource[indexPath.row]];;
            [[PCCHUDManager sharedInstance] dismissHUD];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *segueIdentifier = (self.type == RatingTypeCourse) ? @"segueAddChooseCourse" : @"segueAddChooseProfessor";
                [self performSegueWithIdentifier:segueIdentifier sender:self];
            });
        }];
    }andFailure:^{
        [[PCCHUDManager sharedInstance] updateHUDWithCaption:@"Failed" success:NO];
    }];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"segueAddChooseProfessor"]) {
        PCCAddRatingChooseProfessorViewController *vc = segue.destinationViewController;
        vc.dataSource = [NSOrderedSet orderedSetWithArray:_courses];
    }else if ([segue.identifier isEqualToString:@"segueAddChooseCourse"]) {
        PCCAddRatingChooseCourseViewController *vc = segue.destinationViewController;
        vc.dataSource = [NSOrderedSet orderedSetWithArray:_courses];
    }
}

@end
