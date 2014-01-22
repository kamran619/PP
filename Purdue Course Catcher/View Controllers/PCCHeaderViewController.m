//
//  PCCRegistrationHeaderViewController.m
//  Purdue Course Catcher
//
//  Created by Kamran Pirwani on 1/20/14.
//  Copyright (c) 2014 Kamran Pirwani. All rights reserved.
//

#import "PCCHeaderViewController.h"
#import "MyPurdueManager.h"
#import "Helpers.h"
#import "UIView+Animations.h"

@interface PCCHeaderViewController ()

@end

@implementation PCCHeaderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTerm:(PCCObject *)term
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
        self.term = term;
        [self loadView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.termHeader.text = self.term.key;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeMessage:(NSString *)title message:(NSString *)message image:(NSString *)image
{

    if ([NSThread isMainThread] == NO) {
    NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(changeMessage:message:image:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setSelector:@selector(changeMessage:message:image:)];
    [invocation setTarget:self];
    [invocation setArgument:&title atIndex:2];
    [invocation setArgument:&message atIndex:3];
    [invocation setArgument:&image atIndex:4];
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
    return;
    }

    if (message) self.detailLabel.text = message;
    if (title) self.termHeader.text = title;
    if (image) {
        [self.activityIndicator stopAnimating];
        self.imageView.image = [UIImage imageNamed:image];
        [UIView animateWithDuration:0.5f animations:^{
            self.imageView.alpha = 1.0f;
        }];
    }
}

-(void)dismissHeaderWithDuration:(CGFloat)duration
{
    if ([NSThread isMainThread] == NO) {
        NSMethodSignature *sig = [[self class] instanceMethodSignatureForSelector:@selector(dismissHeaderWithDuration:)];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
        [invocation setSelector:@selector(dismissHeaderWithDuration:)];
        [invocation setTarget:self];
        [invocation setArgument:&duration atIndex:1];
        [invocation retainArguments];
        [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self performSelector:@selector(slideOut) withObject:nil afterDelay:duration];
}

-(void)slideOut
{
    [self.view slideOut];
}

-(void)slideIn
{
    self.view.frame = CGRectMake(0, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [self.view slideIn];
}
-(void)changeMessage:(NSString *)title message:(NSString *)message
{
    [self changeMessage:title message:message image:nil];
}



@end
