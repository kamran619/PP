//
//  PCCAddRatingsViewController.h
//  Course Catcher
//
//  Created by Kamran Pirwani on 8/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCRatingTypeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

enum RatingPhase {
    RatingPhaseChooseCourseOrProfessor,
    RatingPhaseChooseSemester,
    RatingPhaseChooseSpecificCourseOrProfessor,
    RatingPhaseExtraChooseCourseProfessorTaught,
    RatingPhaseActualRatings
} typedef RatingPhase;

@property(nonatomic, strong) IBOutlet UILabel *headerLabel;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, assign) NSInteger phase;

@end
