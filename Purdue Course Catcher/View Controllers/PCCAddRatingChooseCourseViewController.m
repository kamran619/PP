//
//  PCCAddRatingChooseCourseViewController.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCAddRatingChooseCourseViewController.h"
#import "PCFClassModel.h"
#import "PCCUserCourseCell.h"

@interface PCCAddRatingChooseCourseViewController ()

@end

@implementation PCCAddRatingChooseCourseViewController

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
    NSMutableArray *courses = [[_dataSource sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
        PCFClassModel *course = obj1;
        PCFClassModel *courseTwo = obj2;
        return [course.classTitle compare:courseTwo.classTitle];
    }] mutableCopy];
    
    _dataSource = [NSOrderedSet orderedSetWithArray:courses];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCCUserCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kAddRatingCourseCell"];
    PCFClassModel *class = self.dataSource[indexPath.row];
    cell.courseTitle.text = class.classTitle;
    cell.credit.text = [[class.credits substringToIndex:1] stringByAppendingString:@" credits"];
    cell.type.text = class.scheduleType;
    
    return cell;
}


@end
