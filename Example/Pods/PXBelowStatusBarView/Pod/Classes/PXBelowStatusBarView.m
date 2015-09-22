//
//  PXBelowStatusBarView.m
//  PXBelowStatusBarView
//
//  Created by Spencer Phippen on 2015/07/29.
//
//

#import "PXBelowStatusBarView.h"

@interface PXBelowStatusBarView ()
@property (nonatomic,weak) UIViewController* container;
@end

@implementation PXBelowStatusBarView {
    CGFloat _statusBarHeight;
}

- (void) setContainer:(UIViewController*)container {
    _container = container;
    [self setNeedsLayout];
}

- (void) setContainedView:(UIView*)containedView {
    [_containedView removeFromSuperview];
    _containedView = containedView;
    [self addSubview:_containedView];
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];

    if (_container)
        _statusBarHeight = [[_container topLayoutGuide] length];

    CGRect dummy, leftover;
    CGRectDivide([self bounds], &dummy, &leftover, _statusBarHeight, CGRectMinYEdge);
    [_containedView setFrame:leftover];
}

@end
