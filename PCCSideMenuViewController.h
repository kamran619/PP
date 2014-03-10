//
//  PCCSideMenuViewController.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/15/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCCMenuViewController.h"
#import "PCCTermViewController.h"
@class PCCObject;

@interface PCCSideMenuViewController : UIViewController <PCCTermDelegate>
@property (weak, nonatomic) IBOutlet UIButton *search;

-(void)menuItemPressed:(NSString *)itemName;
-(void)termPressed:(PCCObject *)term;

@end
