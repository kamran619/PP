//
//  PCCCatalogViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/2/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCCatalogViewController.h"
#import "KPLightBoxManager.h"

@interface PCCCatalogViewController ()

@end

@implementation PCCCatalogViewController

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
    self.view.layer.cornerRadius = 9.0f;
    [self.scrollView setScrollEnabled:YES];
    
    //calculate text label size
    CGSize textSize = [self.body sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake(250, 20000) lineBreakMode: NSLineBreakByWordWrapping]; //Assuming your width is 240
    
    float heightToAdd = MAX(self.labelBody.frame.size.height, textSize.height);
    BOOL resize = (heightToAdd == self.labelBody.frame.size.height);
    textSize.height = heightToAdd;
    
    self.labelBody.frame = CGRectMake(9, 11, 250, heightToAdd);
    self.labelBody.text = self.body;
    [self.labelBody sizeToFit];
    if (resize) {
        self.view.autoresizesSubviews = NO;
        [self.labelBody sizeToFit];
        //calculate the size between the bottom of the label and top of the button
        CGFloat distance = abs((self.labelBody.frame.size.height + self.labelBody.frame.origin.y) - (self.doneButton.frame.origin.y));
        self.doneButton.frame = CGRectMake(120, self.doneButton.frame.origin.y - distance + 55, 46, 30);
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self
                                     .view.frame.size.height - distance + 65);
    }
    self.labelTitle.text = self.header;
    [self.scrollView setContentSize:textSize];
    [self.scrollView flashScrollIndicators];
    
    [self.doneButton addTarget:self.vc action:@selector(dismissCatalog:) forControlEvents:UIControlEventTouchUpInside];
    
}

@end
