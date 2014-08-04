//
//  PCCAddRatingChooseProfessor.m
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/3/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCAddRatingChooseProfessorViewController.h"
#import "PCFClassModel.h"

@interface PCCAddRatingChooseProfessorViewController ()
{
    NSArray *_professors;
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

@end
