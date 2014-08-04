//
//  PCCAddRatingsViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRatingTypeViewController.h"
#import "KPTransitionManager.h"
#import "PCCHUDManager.h"
#import "Helpers.h"
#import "PCCAddRatingChooseSemesterViewController.h"
#import "MyPurdueManager.h"
#import "PCCRating.h"

@interface PCCRatingTypeViewController ()
{
    NSArray *_terms;
    RatingType _type;
}
@end

@implementation PCCRatingTypeViewController

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
    [[UIBarButtonItem appearanceWhenContainedIn:[self class], nil] setTintColor:[UIColor blackColor]];
    UIBarButtonItem *cancelButton = self.navigationItem.leftBarButtonItem;
    [cancelButton setTarget:self];
    [cancelButton setAction:@selector(dismissMe:)];
    self.phase = RatingPhaseChooseCourseOrProfessor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
    
    // Do any additional setup after loading the
}

- (void)dismissMe:(id)sender {
    [[KPTransitionManager sharedInstance] popTopViewControllerWithAnimationType:KPTransitionTypeFromTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*switch (section) {
        case RatingPhaseChooseCourseOrProfessor:
            return 2;
            break;
        case RatingPhaseChooseSemester:
            return 0;
            break;
        case RatingPhaseChooseSpecificCourseOrProfessor:
            return 0;
            break;
        case RatingPhaseExtraChooseCourseProfessorTaught:
            return 0;
            break;
        case RatingPhaseActualRatings:
            return 0;
            break;
        default:
            return 0;
            break;
    }*/
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kAddRatingCell"];
    
    switch (indexPath.section) {
        case RatingPhaseChooseCourseOrProfessor:
        {
            if (indexPath.row == 0) {
                [cell.textLabel setText:@"Professor"];
            }else if (indexPath.row == 1) {
                [cell.textLabel setText:@"Course"];
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _type = (indexPath.row == 1) ? RatingTypeCourse : RatingTypeProfessor;
    
    [[PCCHUDManager sharedInstance] showHUDWithCaption:@"Loading..."];
    [Helpers asyncronousBlockWithName:@"Retry Terms" AndBlock:^{
        _terms = [MyPurdueManager getMinimalTerms];
        [[PCCHUDManager sharedInstance] dismissHUD];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"segueChooseSemester" sender:self];
        });
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueChooseSemester"]) {
        PCCAddRatingChooseSemesterViewController *vc = [segue destinationViewController];
        [vc setDataSource:_terms];
        [vc setType:_type];
    }
}


@end
