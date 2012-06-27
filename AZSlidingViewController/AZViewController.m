//
//  AZViewController.m
//  AZSlidingViewController
//
//  Created by Patrick Shields on 6/7/12.
//  Copyright 2012 Patrick Shields
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AZViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AZViewController ()
@property(nonatomic, strong)AZSlidingViewController *azvc;
@property(nonatomic, strong)AZSlidingViewController *azvc2;
@end

@implementation AZViewController
@synthesize azvc;
@synthesize azvc2;
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(50, 0, 300, 1024)];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    
	self.azvc = [AZSlidingViewController new];
    [self.view addSubview:self.azvc.view];
    self.azvc.animationLength = 0.5;
    [azvc setContentView:view atDirection:az_sliding_right withMinimumExposed:100];
    self.azvc.delegate = self;
    
    self.azvc2 = [AZSlidingViewController new];
    view = [[UIView alloc] initWithFrame:CGRectMake(500, 0, 300, 1024)];
    gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor grayColor] CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:self.azvc2.view];
    self.azvc2.animationLength = 0.5;
    [azvc2 setContentView:view atDirection:az_sliding_left withMinimumExposed:100];
    self.azvc2.delegate = self;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Change State" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(swapState) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(375, 100, 100, 50);
    [self.view addSubview:button];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)swapState
{
    self.azvc.slidingState = !self.azvc.slidingState;
    self.azvc2.slidingState = !self.azvc2.slidingState;
}

#pragma mark AZSlidingViewControllerDelegate
- (void)azSlidingViewController:(AZSlidingViewController *)viewController willChangeStateTo:(AZSlidingDirection)newState
{
    NSLog(@"New state will be %@", az_sliding_right == newState ? @"right" : @"left");
}

- (void)azSlidingViewController:(AZSlidingViewController *)viewController didChangeStateTo:(AZSlidingDirection)newState
{
    NSLog(@"New state is %@", az_sliding_right == newState ? @"right" : @"left");
}

- (void)azSlidingViewControllerWillBeginSliding:(AZSlidingViewController *)viewController
{
    NSLog(@"Beginning the slide");
}
@end
