//
//  KPLightBoxManager.h
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPLightBoxManager : NSObject

+(instancetype) sharedInstance;
-(void)showLightBox;
-(void)dismissLightBox;

@property (nonatomic, assign) NSInteger animationDuration;
@property (nonatomic, strong) UIView *lightBoxView;
@property (nonatomic, assign) CGFloat alpha;

@end
