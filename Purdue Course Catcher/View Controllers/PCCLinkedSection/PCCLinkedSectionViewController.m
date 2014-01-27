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
#import "PCCDataManager.h"

@interface PCCLinkedSectionViewController ()
{
    int position;
    NSMutableArray *layeredClasses;
    NSMutableArray *selectedCells;
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
        //self.name = title;
        //self.header.text = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.courseName.text = self.course.courseNumber;
    self.courseTitle.text = self.course.classTitle;
    self.type.text = self.course.scheduleType;
    self.days.text = self.course.days;
    position = 0;
    layeredClasses = [[NSMutableArray alloc] initWithCapacity:3];
    selectedCells = [[NSMutableArray alloc] initWithCapacity:3];
    lastSelectedClass = [[PCFClassModel alloc] init];
    [self trimDataSource];
    [self getLinkedLayerForClass:nil];
    [self.tableView.layer setCornerRadius:4.0f];
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
    
    NSArray *array = set.allObjects;
    array = [array sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"days" ascending:YES comparator:^(id obj1, id obj2) {
        //PCFClassModel *class = (PCFClassModel *)obj1;
        //PCFClassModel *classTwo = (PCFClassModel *)obj2;
        
        NSString *classOneDay = (NSString *)obj1;
        NSString *classTwoDay = (NSString *)obj2;
        
        int rankOne = [self getRank:classOneDay];
        int rankTwo = [self getRank:classTwoDay];
        
        if (rankOne < rankTwo) return NSOrderedDescending;
        if (rankOne > rankTwo) return NSOrderedAscending;
        
        return NSOrderedSame;
    }], [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES comparator:^(id obj1, id obj2) {
        
            NSArray *timeArrayOne = [Helpers splitTime:obj1];
            NSArray *timeArrayTwo = [Helpers splitTime:obj2];
            
            NSInteger timeOneStart = [Helpers getIntegerRepresentationOfTime:[timeArrayOne objectAtIndex:0]];
            NSInteger timeOneEnd = [Helpers getIntegerRepresentationOfTime:[timeArrayOne objectAtIndex:1]];
            
            NSInteger timeTwoStart = [Helpers getIntegerRepresentationOfTime:[timeArrayTwo objectAtIndex:0]];
            NSInteger timeTwoEnd = [Helpers getIntegerRepresentationOfTime:[timeArrayTwo objectAtIndex:1]];
            
            if (timeOneStart < timeTwoStart) return (NSComparisonResult)NSOrderedAscending;
            if (timeOneStart > timeTwoStart) return (NSComparisonResult)NSOrderedDescending;
            
            //equal
            if (timeOneEnd < timeTwoEnd) {
                return NSOrderedAscending;
            }else if (timeOneEnd < timeTwoEnd) {
                return NSOrderedDescending;
            }else {
                return NSOrderedSame;
            }
    }], nil]];
    if (array.count > 0) [layeredClasses insertObject:array atIndex:position];
    
    return YES;
}

-(int)getRank:(NSString *)str
{
    NSString *letter = [str substringToIndex:1];
    if ([letter isEqualToString:@"M"]) {
        return 0;
    }else if ([letter isEqualToString:@"T"]) {
        return 1;
    }else if ([letter isEqualToString:@"W"]) {
        return 2;
    }else if ([letter isEqualToString:@"R"]) {
        return 3;
    }else if ([letter isEqualToString:@"F"]) {
        return 4;
    }else {
        return 5;
    }
}
-(IBAction)dismissPressed:(id)sender
{
    NSMutableSet *set = [NSMutableSet setWithCapacity:3];
    for (PCFClassModel *class in self.dataSource) {
        [set addObject:class.scheduleType];
    }
    [set removeObject:@"Distance Learning"];
    //+ 1 for ourself
    BOOL registrationComplete = (selectedCells.count + 1 == set.count);
    NSMutableArray *arrayRegister = [PCCDataManager sharedInstance].arrayRegister;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (registrationComplete) {
            for (NSIndexPath *indexPath in selectedCells) {
                PCFClassModel *class = [[layeredClasses objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                if (![arrayRegister containsObject:class]) [arrayRegister addObject:class];
            }
            if (![arrayRegister containsObject:self.course])[arrayRegister addObject:self.course];
        }
    });
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(completedRegistrationForClass:)]) {
            [self.delegate completedRegistrationForClass:registrationComplete];
        }
    }];
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
    
    if (selectedCells.count > indexPath.section && [selectedCells objectAtIndex:indexPath.section]) {
        //we are clicking a cell when we already have a new one
        NSIndexPath *path = [selectedCells objectAtIndex:indexPath.section];
        [tableView deselectRowAtIndexPath:path animated:NO];
        [selectedCells removeObject:path];
        NSRange range = NSMakeRange(position, layeredClasses.count-1);
        [layeredClasses removeObjectsInRange:range];
        [tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationAutomatic];
        position = indexPath.section;
    }
    if (!layeredClasses.count > indexPath.section) return;
        NSArray *array = [layeredClasses objectAtIndex:indexPath.section];
        PCFClassModel *class = [array objectAtIndex:indexPath.row];
        [selectedCells insertObject:indexPath atIndex:position];
        position++;
        if ([self getLinkedLayerForClass:class]) {
            [tableView insertSections:[NSIndexSet indexSetWithIndex:position] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:position] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }else {
            position--;
        }

    
   
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selectedCells removeObject:indexPath];
    NSRange range = NSMakeRange(position, layeredClasses.count-1);
    [layeredClasses removeObjectsInRange:range];
    [tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationAutomatic];
    position = indexPath.section;
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
    if (array.count < section) return nil;
    PCFClassModel *class = [array objectAtIndex:0];
    return class.scheduleType;
}

@end
