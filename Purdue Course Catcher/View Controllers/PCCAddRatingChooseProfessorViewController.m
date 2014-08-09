//
//  PCCAddRatingChooseProfessor.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCAddRatingChooseProfessorViewController.h"
#import "PCFClassModel.h"
#import "PCCAddRatingChooseCourseViewController.h"

@interface PCCAddRatingChooseProfessorViewController ()
{
    NSArray *_professors;
    NSString *_selectedProfessor;
}
@end

@implementation PCCAddRatingChooseProfessorViewController

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

    NSMutableArray *professors = [NSMutableArray array];
    [_dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PCFClassModel *class = obj;
        if (![professors containsObject:class.instructor]) {
            [professors addObject:class.instructor];
        }
    }];
    
    professors = [[professors sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }] mutableCopy];
    
    _professors = [professors copy];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _professors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kAddRatingProfessorCell"];
    NSString *professorName = _professors[indexPath.row];
    cell.textLabel.text = professorName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedProfessor = _professors[indexPath.row];
    [self performSegueWithIdentifier:@"segueAddChooseCourse" sender:self];
    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueAddChooseCourse"]) {
        PCCAddRatingChooseCourseViewController *vc = segue.destinationViewController;
        vc.dataSource = [NSOrderedSet orderedSetWithArray:[self getClassesForProfessor:_selectedProfessor]];
    }
}

- (NSArray *)getClassesForProfessor:(NSString *)professor {
    NSMutableArray *courses = [NSMutableArray array];
    
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PCFClassModel *class = (PCFClassModel *)obj;
        if ([class.instructor isEqualToString:professor])
            [courses addObject:class];
    }];
    
    return [courses copy];
}

@end
