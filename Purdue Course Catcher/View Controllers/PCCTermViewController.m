//
//  PCCTermViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/18/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCTermViewController.h"
#import "PCCObject.h"
@interface PCCTermViewController ()
{
    PCCObject *selectedObject;
}
@end

@implementation PCCTermViewController

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
    PCCObject *firstObject = [self.dataSource objectAtIndex:0];
    selectedObject = [[PCCObject alloc] initWithKey:firstObject.key AndValue:firstObject.value];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneButtonPressed:(id)sender
{
    if ([self.delgate respondsToSelector:@selector(termPressed:)]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delgate termPressed:selectedObject];
        }];
    }
}

#pragma mark UIPickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    PCCObject *tempObject = [self.dataSource objectAtIndex:row];
    selectedObject.key = tempObject.key;
    selectedObject.value = tempObject.value;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PCCObject *obj = [self.dataSource objectAtIndex:row];
    return obj.key;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 300;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

#pragma mark UIPickerView Data Source
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSource.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


@end
