//
//  PCCStoreCell.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 3/10/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCCStoreCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *price;
@property (nonatomic, strong) IBOutlet UIButton *purchaseButton;

@end
