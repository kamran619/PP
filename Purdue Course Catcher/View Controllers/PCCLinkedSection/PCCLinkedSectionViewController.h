//
//  PCCLinkedSectionViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/23/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCFClassModel;
@interface PCCLinkedSectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithTitle:(NSString *)title;

@property (nonatomic, strong) IBOutlet UILabel *header;
@property (nonatomic, strong) IBOutlet UILabel *detail;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;

@property (nonatomic, strong) PCFClassModel *course;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSSet *sectionNames;
@property (nonatomic, strong) NSString *title;
@end
