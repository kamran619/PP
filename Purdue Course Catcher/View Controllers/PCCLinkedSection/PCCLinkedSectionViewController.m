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
#import "Helpers.h"
#import "UIView+Animations.h"

@interface PCCLinkedSectionViewController ()
{
    int position;
    NSMutableArray *layeredClasses;
    PCFClassModel *lastSelectedClass;
    BOOL extraMatching;
}

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
    self = (PCCLinkedSectionViewController *)[Helpers viewControllerWithStoryboardIdentifier:@"PCCLinkedSection"];
    if (self) {
        // Custom initialization
        self.title = title;
        //self.header.text = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.header.text = self.title;
    position = 0;
    layeredClasses = [[NSMutableArray alloc] initWithCapacity:3];
    lastSelectedClass = [[PCFClassModel alloc] init];
    [self trimDataSource];
    [self getLinkedLayerForClass:nil];
    [self.tableView reloadData];
    //[self initSections];
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
    
    [array removeObject:self.course];
    self.dataSource = array;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)getLinkedLayerForClass:(PCFClassModel *)class
{
    extraMatching = NO;
    
    if ([self.course.linkedSection isEqualToString:class.linkedID]) {
        [self.doneButton pulse];
        return NO;
    }
    
    if (!class) {
        class = self.course;
    }else if (![class isEqual:self.course]) {
        extraMatching = YES;
    }
    
    NSMutableSet *set = [NSMutableSet setWithCapacity:4];
    for (PCFClassModel *course in self.dataSource) {
        if ([class.linkedID isEqualToString:course.linkedSection]) {
            if (extraMatching) {
                if (![self.course.linkedSection isEqualToString:course.linkedID]) continue;
            }
            
            [set addObject:course];
            NSString *message = [NSString stringWithFormat:@"Added LinkID %@ and LinkedSection %@ to set\n", course.linkedID, course.linkedSection];
            NSLog(@"%@", message);
        }
    }
    
    [layeredClasses insertObject:set.allObjects atIndex:position];
    
    return YES;
}

-(IBAction)dismissPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UITableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PCFClassModel *class = [[layeredClasses objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
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
    NSArray *array = [layeredClasses objectAtIndex:indexPath.section];
    PCFClassModel *class = [array objectAtIndex:0];
    position++;
    if ([self getLinkedLayerForClass:class]) {
         [tableView insertSections:[NSIndexSet indexSetWithIndex:position] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:position] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }else {
        position--;
    }
   
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[layeredClasses objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return layeredClasses.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *array = [layeredClasses objectAtIndex:section];
    PCFClassModel *class = [array objectAtIndex:0];
    return class.scheduleType;
}


@end
