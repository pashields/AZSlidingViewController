//
//  AZSlidingViewController.m
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

#import "AZSlidingViewController.h"

#ifndef AZ_DEBUG
#define AZ_DEBUG(x) NSLog(x)
#endif

typedef void (^AnimationBlock)();
typedef void (^AnimationCompletionBlock)(BOOL finished);

@interface AZSlidingViewController () <UIScrollViewDelegate> 
@property(nonatomic, strong, readwrite)UIView *contentView;
@property(nonatomic, assign)CGFloat minimumExposed;
@property(nonatomic, assign)AZSlidingDirection initialState;
@property(nonatomic, assign)CGRect initialRect;
@property(nonatomic, readonly)CGFloat maxCovered;
@property(nonatomic, assign)BOOL dragging;
@property(nonatomic, strong)NSOperationQueue *queue;
@end

@implementation AZSlidingViewController
@synthesize contentView;
@synthesize slidingState;
@synthesize minimumExposed;
@synthesize scrollView;
@synthesize initialRect;
@synthesize initialState;
@synthesize animationLength;
@synthesize delegate;
@synthesize dragging;
@synthesize queue;

- (id)initWithContentView:(UIView *)_contentView atDirection:(AZSlidingDirection)direction withMinimumExposed:(CGFloat)_minimumExposed
{
    self = [super init];
    if (self) {
        [self setContentView:_contentView atDirection:direction withMinimumExposed:_minimumExposed];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.scrollView removeFromSuperview];
}

- (void)setContentView:(UIView *)_contentView atDirection:(AZSlidingDirection)direction withMinimumExposed:(CGFloat)_minimumExposed
{
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.autoresizesSubviews = NO;
    self.view = self.scrollView;
    
    [self.contentView removeFromSuperview];
    self.contentView = _contentView;
    
    [self.scrollView addSubview:self.contentView];
    
    self.minimumExposed = _minimumExposed;
    self.initialState = direction;
    self.initialRect = self.contentView.frame;
    self.scrollView.frame = self.initialRect;
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width + self.maxCovered, 
                                             self.contentView.frame.size.height);
    CGRect contentFrame = self.contentView.frame;
    if (az_sliding_right == direction) {
        contentFrame.origin.x = 0;
    } else {
        contentFrame.origin.x = self.maxCovered;
    }
    self.contentView.frame = contentFrame;
    
    NSTimeInterval animationLengthCopy = self.animationLength;
    self.animationLength = 0;
    
    self.slidingState = direction;
    
    self.animationLength = animationLengthCopy;
    
    [self.scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.scrollView && [keyPath isEqualToString:@"frame"]) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.frame.size.height);
        NSValue *oldFrameValue = [change objectForKey:NSKeyValueChangeOldKey];
        CGRect oldFrame = oldFrameValue.CGRectValue;
        CGFloat rightChange = (oldFrame.origin.x + oldFrame.size.width) - (self.scrollView.frame.origin.x + self.scrollView.frame.size.width);
        CGRect _initialRect = self.initialRect;
        _initialRect.origin.x -= rightChange;
        self.initialRect = _initialRect;
    }
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"frame"];
}

- (void)_setSlidingState:(NSNumber *)packedSlidingState
{
    [self.queue setSuspended:YES];
    
    AZSlidingDirection oldState = slidingState;
    
    AZSlidingDirection _slidingState = [packedSlidingState intValue];
    slidingState = _slidingState;
    if (self.dragging) {
        self.dragging = NO;
    } else {
        if ([self.delegate respondsToSelector:@selector(azSlidingViewControllerWillBeginSliding:)]) {
            [self.delegate azSlidingViewControllerWillBeginSliding:self];
        }
    }
    AnimationBlock animations; AnimationCompletionBlock completion;
    
    if ([self.delegate respondsToSelector:@selector(azSlidingViewController:willChangeStateTo:)]) {
        [self.delegate azSlidingViewController:self
                             willChangeStateTo:_slidingState];
    }
    
    if (az_sliding_right == initialState && az_sliding_right == slidingState) {
        AZ_DEBUG(@"Right");
        [self expandScrollView];
        animations = ^{
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = 0;
            self.scrollView.contentOffset = offset;
        };
        completion = ^(BOOL finished) {};
    } else if (az_sliding_right == initialState && az_sliding_left == slidingState) {
        AZ_DEBUG(@"Left");
        animations = ^{
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = self.maxCovered;
            self.scrollView.contentOffset = offset;
        };
        completion = ^(BOOL finished) {
            [self contractScrollView];
        };
    } else if (az_sliding_left == initialState && az_sliding_left == slidingState) {
        AZ_DEBUG(@"Left");
        [self expandScrollView];
        animations = ^{
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = self.maxCovered;
            self.scrollView.contentOffset = offset;
        };
        completion = ^(BOOL finished) {};
    } else {
        AZ_DEBUG(@"Right");
        animations = ^{
            if (oldState != slidingState) {
                CGPoint offset = self.scrollView.contentOffset;
                offset.x = 0;
                self.scrollView.contentOffset = offset;
            }
        };
        completion = ^(BOOL finished) {
            [self contractScrollView];
        };
    }
    [UIView animateWithDuration:self.animationLength
                          delay:0
                        options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction
                     animations:animations
                     completion:^(BOOL finished) {
                         completion(finished);
                         [self.queue setSuspended:NO];
                         if ([self.delegate respondsToSelector:@selector(azSlidingViewController:didChangeStateTo:)]) {
                             [self.delegate azSlidingViewController:self
                                                   didChangeStateTo:_slidingState];
                         }
                     }];
}

- (void)setSlidingState:(AZSlidingDirection)_slidingState
{
    NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Starting Job");
        [self performSelectorOnMainThread:@selector(_setSlidingState:) 
                               withObject:[NSNumber numberWithInt:_slidingState]
                            waitUntilDone:YES];
    }];
    [self.queue addOperation:op];
}

- (AZSlidingDirection)slidingState
{
    return self.dragging ? !slidingState : slidingState;
}

- (void)expandScrollView
{
    AZ_DEBUG(@"Expand");
    CGRect scrollViewRect = self.scrollView.frame;
    scrollViewRect.size.width = self.initialRect.size.width;
    if (az_sliding_left == self.initialState && az_sliding_left == self.slidingState) {
        if (scrollViewRect.origin.x != self.initialRect.origin.x) {
            CGPoint offset = self.scrollView.contentOffset;
            offset.x = 0;
            self.scrollView.delegate = nil;
            self.scrollView.contentOffset = offset;
            self.scrollView.delegate = self;
            scrollViewRect.origin.x = self.initialRect.origin.x;
        }
    }
    self.scrollView.frame = scrollViewRect;
}

- (void)contractScrollView
{
    AZ_DEBUG(@"Contract");
    CGRect scrollViewRect = self.scrollView.frame;
    scrollViewRect.size.width = self.initialRect.size.width - self.maxCovered;
    if (az_sliding_right == self.slidingState) {
        CGPoint offset = self.scrollView.contentOffset;
        offset.x = self.maxCovered;
        self.scrollView.contentOffset = offset;
        scrollViewRect.origin.x = self.initialRect.origin.x + self.maxCovered;
    }
    self.scrollView.frame = scrollViewRect;
}

- (CGFloat)maxCovered
{
    return self.contentView.frame.size.width - self.minimumExposed;
}
#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(azSlidingViewControllerWillBeginSliding:)]) {
        [self.delegate azSlidingViewControllerWillBeginSliding:self];
    }
    self.dragging = YES;
    [self expandScrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)_scrollView willDecelerate:(BOOL)decelerate
{
    AZ_DEBUG(@"Done Dragging");
    if (!decelerate) {
        AZ_DEBUG(@"Calling decel");
        [self scrollViewDidEndDecelerating:_scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    AZ_DEBUG(@"Done Decelerating");
    if (self.scrollView.contentOffset.x > self.maxCovered / 2) {
        self.slidingState = az_sliding_left;
    } else {
        self.slidingState = az_sliding_right;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(azSlidingViewControllerDidSlide:)]) {
        [self.delegate azSlidingViewControllerDidSlide:self];
    }
}
@end
