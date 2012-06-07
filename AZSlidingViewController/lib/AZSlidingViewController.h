//
//  AZSlidingViewController.h
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

#import <UIKit/UIKit.h>

typedef enum {
    az_sliding_left,
    az_sliding_right
} AZSlidingDirection;

@class AZSlidingViewController;

@protocol AZSlidingViewControllerDelegate <NSObject>
@optional
- (void)azSlidingViewController:(AZSlidingViewController *)viewController willChangeStateTo:(AZSlidingDirection)newState;
- (void)azSlidingViewController:(AZSlidingViewController *)viewController didChangeStateTo:(AZSlidingDirection)newState;
- (void)azSlidingViewControllerDidSlide:(AZSlidingViewController *)viewController;
@end

@interface AZSlidingViewController : UIViewController
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong, readonly)UIView *contentView;
@property(nonatomic, assign)AZSlidingDirection slidingState;
@property(nonatomic, assign)NSTimeInterval animationLength;
@property(nonatomic, weak)id<AZSlidingViewControllerDelegate> delegate;

- (id)initWithContentView:(UIView *)contentView atDirection:(AZSlidingDirection)direction withMinimumExposed:(CGFloat)minimumExposed;
- (void)setContentView:(UIView *)contentView atDirection:(AZSlidingDirection)direction withMinimumExposed:(CGFloat)minimumExposed;
@end
