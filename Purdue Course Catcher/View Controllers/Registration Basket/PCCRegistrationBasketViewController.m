//
//  PCCRegistrationBasketViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/22/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCRegistrationBasketViewController.h"
#import "Helpers.h"
@interface PCCRegistrationBasketViewController ()

@end

@implementation PCCRegistrationBasketViewController

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
    self.basket.layer.anchorPoint = CGPointMake(0.5, 1);
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self wiggleBasket];
}

-(void)wiggleBasket
{
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.basket.transform = CGAffineTransformMakeRotation(RADIANS(7));
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.basket.transform = CGAffineTransformRotate(self.basket.transform, (RADIANS(-14)));
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.basket.transform = CGAffineTransformIdentity;
            }completion:nil];
        }];
    }];
}


- (IBAction)dismissPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
