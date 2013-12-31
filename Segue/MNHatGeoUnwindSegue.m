//
//  MNHatGeoUnwindSegue.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 12/29/13.
//  Copyright (c) 2013 Kamran Pirwani. All rights reserved.
//

#import "MNHatGeoUnwindSegue.h"
#import "MHNatGeoViewControllerTransition.h"
@implementation MNHatGeoUnwindSegue

- (void)perform
{
    [self.destinationViewController dismissNatGeoViewController];
}
@end
