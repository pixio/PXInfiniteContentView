//
//  PXViewController.m
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 09/21/2015.
//  Copyright (c) 2015 Spencer Phippen. All rights reserved.
//

#import "PXViewController.h"

#import <PXBelowStatusBarView/PXBelowStatusBarView.h>
#import <PXInfiniteContentView/PXInfiniteContentView.h>
#import <SPHStringContentFillView/SPHStringContentFillView.h>
#import <PXMultiForwarder/PXMultiForwarder.h>

@interface PXViewController () <PXInfiniteContentViewDelegate>
@end

@implementation PXViewController

- (void) loadView {
    PXBelowStatusBarView* v = [PXBelowStatusBarView new];
    [v setBackgroundColor:[UIColor whiteColor]];
    PXInfiniteContentView* content = [[PXInfiniteContentView alloc] initWithViewClass:[SPHStringContentFillView class]];
    [v setContainedView:content];
    [self setView:v];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[self infiniteContentView] setDelegate:self];
    
    // uncomment to test bounds
//    [[self infiniteContentView] setPageIndexBounds:[PXPageIndexBounds lowerBound:-3 upperBound:3]];
    
    [[self allViews] setBackgroundColor:[UIColor whiteColor]];
}

- (PXInfiniteContentView*) infiniteContentView {
    return (PXInfiniteContentView*)[(PXBelowStatusBarView*)[self view] containedView];
}

- (SPHStringContentFillView*) leftView {
    return (SPHStringContentFillView*)[[self infiniteContentView] leftView];
}
- (SPHStringContentFillView*) centerView {
    return (SPHStringContentFillView*)[[self infiniteContentView] centerView];
}
- (SPHStringContentFillView*) rightView {
    return (SPHStringContentFillView*)[[self infiniteContentView] rightView];
}
- (SPHStringContentFillView*) allViews {
    return (SPHStringContentFillView*)[[PXMultiForwarder alloc] initWithObjects:[self leftView], [self centerView], [self rightView], nil];
}

#pragma mark PXInfiniteContentViewDelegate Methods
- (void) infiniteContentView:(PXInfiniteContentView*)infiniteContentView transitionedToIndex:(int)index {
    [[self allViews] regenerate];
}

- (void) infiniteContentView:(PXInfiniteContentView*)infiniteContentView willShowView:(SPHStringContentFillView*)view forIndex:(int)index {
    [view setContentString:[NSString stringWithFormat:@"Content@%+d", index]];
}

@end
