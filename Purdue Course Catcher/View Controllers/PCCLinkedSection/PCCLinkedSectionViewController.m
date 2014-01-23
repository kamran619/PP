//
//  PCCLinkedSectionViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/23/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCLinkedSectionViewController.h"
#import "PCFClassModel.h"
#import "PCCRegistrationCell.h"

@interface PCCLinkedSectionViewController ()

@end

@implementation PCCLinkedSectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithNibName:@"PCCLinkedSectionViewController" bundle:nil];
    if (self) {
        // Custom initialization
        [self loadView];
        self.header.text = title;
        self.tableView.layer.cornerRadius = 4.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self trimDataSource];
    [self initSections];
    // Do any additional setup after loading the view from its nib.
}

-(void)trimDataSource
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    
    for (int i = 0; i < self.dataSource.count; i++) {
        PCFClassModel *class = [self.dataSource objectAtIndex:i];
        if ([class.courseNumber isEqualToString:self.course.courseNumber] && [class.classTitle isEqualToString:self.course.classTitle]) {
            [array addObject:class];
        }
    }
    
    self.dataSource = array;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)firstLayerLinked
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:4];
    for (PCFClassModel *class in self.dataSource) {
        if ([self.course.linkedID isEqualToString:class.linkedSection]) [set addObject:class];
    }
    
    return set.allObjects;
}

-(void)initSections
{
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:3];
    for (PCFClassModel *class in self.dataSource) {
        [set addObject:class.scheduleType];
    }
    
    self.sectionNames = set.copy;
}

-(IBAction)dismissPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCFClassModel *class = [[self firstLayerLinked] objectAtIndex:indexPath.row];
    PCCRegistrationCell *cell = (PCCRegistrationCell *)[tableView dequeueReusableCellWithIdentifier:@"kRegistrationCell"];
    [cell.days setText:class.days];
    [cell.time setText:class.time];
    [cell.instructor setText:class.instructor];
    [cell.location setText:class.classLocation];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCCRegistrationCell *cell = (PCCRegistrationCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [self firstLayerLinked].count;
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionNames.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = [self.sectionNames allObjects];
    return [array objectAtIndex:section];
}


@end
