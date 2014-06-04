//
//  PCCTabBarController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/29/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCTabBarController.h"
#import "Helpers.h"

@interface PCCTabBarController ()

@end

@implementation PCCTabBarController

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
    self.tabBar.layer.borderColor = [Helpers purdueColor:PurdueColorLightGrey].CGColor;
    self.tabBar.layer.borderWidth = 0.5f;
    UITabBarItem *searchItem = [[self.tabBar items] objectAtIndex:0];
    [searchItem setImage:[UIImage imageNamed:@"search_normal.png"]];
    [searchItem setSelectedImage:[UIImage imageNamed:@"search_selected.png"]];
    UITabBarItem *scheduleItem = [[self.tabBar items] objectAtIndex:1];
    [scheduleItem setSelectedImage:[UIImage imageNamed:@"schedule_selected.png"]];
    [scheduleItem setImage:[UIImage imageNamed:@"schedule_normal.png"]];
    UITabBarItem *ratingsItem = [[self.tabBar items] objectAtIndex:2];
    [ratingsItem setSelectedImage:[UIImage imageNamed:@"ratings_selected.png"]];
    [ratingsItem setImage:[UIImage imageNamed:@"ratings_normal.png"]];
    UITabBarItem *notificationsItem = [[self.tabBar items] objectAtIndex:3];
    [notificationsItem setImage:[UIImage imageNamed:@"notification_normal.png"]];
    [notificationsItem setSelectedImage:[UIImage imageNamed:@"notification_selected.png"]];
    UITabBarItem *settingsItem = [[self.tabBar items] objectAtIndex:4];
    [settingsItem setImage:[UIImage imageNamed:@"settings_normal.png"]];
    [settingsItem setSelectedImage:[UIImage imageNamed:@"settings_selected.png"]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
