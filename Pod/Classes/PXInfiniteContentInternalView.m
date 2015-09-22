//
//  PXInfiniteContentInternalView.m
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/19.
//
//

#import "PXInfiniteContentInternalView.h"

typedef NS_ENUM(NSInteger, PXInfiniteContentInternalState) {
    PXInfiniteContentInternalNotMovingState,
    PXInfiniteContentInternalScrollingState,
    PXInfiniteContentInternalFinishingTransitionState
};

@interface PXInfiniteContentInternalView () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@end

@implementation PXInfiniteContentInternalView {
    PXInfiniteContentInternalState _state;
    
    BOOL _hasAfterTransitionIndex;
    int _afterTransitionIndex;
    PXInfiniteContentBounds* _afterTransitionBounds;
}

#pragma mark Constructors
- (instancetype) init {
    NSAssert(FALSE, @"Bad init function");
    return nil;
}

- (instancetype) initWithFrame:(CGRect)frame {
    NSAssert(FALSE, @"Bad init function");
    return nil;
}

- (instancetype) initWithLeftView:(id)leftView centerView:(id)centerView rightView:(id)rightView {
    NSParameterAssert(leftView);
    NSParameterAssert(centerView);
    NSParameterAssert(rightView);
    
    
    self = [super initWithFrame:CGRectZero];
    if (!self)
        return nil;

    _state = PXInfiniteContentInternalNotMovingState;
    _index = 0;
    _contentBounds = [PXInfiniteContentBounds noBounds];
    _afterTransitionBounds = [PXInfiniteContentBounds noBounds];
    
    [self setDelaysContentTouches:FALSE];
    [self setBounces:FALSE];
    [self setShowsHorizontalScrollIndicator:FALSE];
    [self setShowsVerticalScrollIndicator:FALSE];
    [self setPagingEnabled:TRUE];
    [self setDirectionalLockEnabled:TRUE];

    _leftView = leftView;
    _centerView = rightView;
    _rightView = centerView;
    
    [self addSubview:_leftView];
    [self addSubview:_centerView];
    [self addSubview:_rightView];
    
    [self setDelegate:self];
    
    return self;
}

#pragma mark Properties
- (void) setLeftView:(id)leftView {
    id oldLeftView = _leftView;
    _leftView = leftView;
    [self addSubview:_leftView];
    [_leftView setFrame:[oldLeftView frame]];
    [oldLeftView removeFromSuperview];
}

- (void) setCenterView:(id)centerView {
    id oldCenterView = _centerView;
    _centerView = centerView;
    [self addSubview:_centerView];
    [_centerView setFrame:[oldCenterView frame]];
    [oldCenterView removeFromSuperview];
}

- (void) setRightView:(id)rightView {
    id oldRightView = _rightView;
    _rightView = rightView;
    [self addSubview:_rightView];
    [_rightView setFrame:[oldRightView frame]];
    [oldRightView removeFromSuperview];
}

- (void) setIndex:(int)index {
    [self setIndex:index notify:TRUE];
}

- (void) setIndex:(int)index notify:(BOOL)notify {
    if (_state == PXInfiniteContentInternalNotMovingState) {
        const int oldIndex = _index;
        _index = [_contentBounds clampValue:index];
        if (_index != oldIndex && notify) {
            [self notifyInternalDelegateOfTransitionToIndex:_index];
            [self notifyInternalDelegateOfShowView:_centerView forIndex:_index];
        }
    } else {
        _hasAfterTransitionIndex = TRUE;
        _afterTransitionIndex = index;
    }
}

- (void) setContentBounds:(PXInfiniteContentBounds*)contentBounds {
    NSParameterAssert(contentBounds);
    if (_state == PXInfiniteContentInternalNotMovingState) {
        _contentBounds = contentBounds;
        _index = [_contentBounds clampValue:_index];
    }
    _afterTransitionBounds = _contentBounds;
}

- (void) notifyInternalDelegateOfTransitionToIndex:(int)index {
    if (_internalDelegate)
        [_internalDelegate internalInfiniteContentView:self transitionedToIndex:index];
}

- (void) notifyInternalDelegateOfShowView:(id)view forIndex:(int)index {
    if ([_contentBounds clampValue:index] != index) {
        return;
    }
    
    if (_internalDelegate)
        [_internalDelegate internalInfiniteContentView:self willShowView:view forIndex:index];
}

#pragma mark UIView Methods
- (void) layoutSubviews {
    [super layoutSubviews];

    BOOL onLeftBoundary = [_contentBounds hasLowerBound] && _index == [_contentBounds lowerBound];
    BOOL onRightBoundary = [_contentBounds hasUpperBound] && _index == [_contentBounds upperBound];
    
    int sizeMultiplier = 3 - (!!onLeftBoundary) - (!!onRightBoundary);
    const CGRect entireArea = [self bounds];
    // We add 1e-2 to the height to make the scroll view think it can scroll vertically.
    // If we don't do this, the pan gesture recognizer doesn't get a chance to process the touch
    // events and can't fail (which is a problem because we make all other other gesture recognizers
    // require the pan gesture recognizer to fail).
    const CGSize contentSize = CGSizeMake(entireArea.size.width * sizeMultiplier, entireArea.size.height + 1e-2);
    [self setContentSize:contentSize];
    
    const CGFloat xOffset = onLeftBoundary ? -entireArea.size.width : 0;
    const CGRect leftArea = CGRectMake(xOffset, 0, entireArea.size.width, entireArea.size.height);
    const CGRect centerArea = CGRectMake(xOffset + entireArea.size.width, 0, entireArea.size.width, entireArea.size.height);
    const CGRect rightArea = CGRectMake(xOffset + 2*entireArea.size.width, 0, entireArea.size.width, entireArea.size.height);
    
    if (_state == PXInfiniteContentInternalNotMovingState) {
        const CGPoint desiredOffset = CGPointMake(entireArea.size.width, 0.0);
        if (!CGPointEqualToPoint(desiredOffset, [self contentOffset])) {
            [self setContentOffset:desiredOffset animated:FALSE];
        }
    }
    
    [_centerView setFrame:centerArea];
    [_leftView setFrame:leftArea];
    [_rightView setFrame:rightArea];
}

#pragma mark PXInfiniteContentInternalView Methods
- (void) moveToState:(PXInfiniteContentInternalState)state {
    switch (state) {
        case PXInfiniteContentInternalNotMovingState: {
            if (_state == PXInfiniteContentInternalScrollingState ||
                _state == PXInfiniteContentInternalFinishingTransitionState) {
                const CGFloat centerThreshold = [self bounds].size.width;
                const BOOL isCenter = fabs([self contentOffset].x - centerThreshold) < 0.5;
                const BOOL isLeft = !isCenter && [self contentOffset].x < centerThreshold;
                const BOOL isRight = !isCenter && !isLeft && [self contentOffset].x > centerThreshold;
                
                const id oldLeft = _leftView;
                const id oldCenter = _centerView;
                const id oldRight = _rightView;
                if (isCenter) {
                    // Do nothing
                } else if (isLeft) {
                    _leftView = oldRight;
                    _centerView = oldLeft;
                    _rightView = oldCenter;
                    _index -= 1;
                } else if (isRight) {
                    _leftView = oldCenter;
                    _centerView = oldRight;
                    _rightView = oldLeft;
                    _index += 1;
                }
            }
            _state = state;

            [self setContentBounds:_afterTransitionBounds];
            if (_hasAfterTransitionIndex) {
                [self setIndex:_afterTransitionIndex notify:FALSE];
                _hasAfterTransitionIndex = FALSE;
            }
            [self notifyInternalDelegateOfTransitionToIndex:_index];

            [self setNeedsLayout];
            break;
        }
        case PXInfiniteContentInternalScrollingState: {
            NSAssert(_state == PXInfiniteContentInternalNotMovingState, @"Bad state transition");
            _state = state;
            break;
        }
        case PXInfiniteContentInternalFinishingTransitionState: {
            NSAssert(_state == PXInfiniteContentInternalNotMovingState ||
                     _state == PXInfiniteContentInternalScrollingState, @"Bad state transition");
            _state = state;
            break;
        }
    }
}

- (void) animateChangeWithOffset:(int)offset {
    if (_state == PXInfiniteContentInternalNotMovingState) {
        const int newIndex = [_contentBounds clampValue:_index + offset];
        const int realOffset = newIndex - _index;
        if (realOffset == 0) {
            return;
        } else if (realOffset < 0) {
            [self notifyInternalDelegateOfShowView:_leftView forIndex:newIndex];
            [self moveToState:PXInfiniteContentInternalFinishingTransitionState];
            CGPoint newOffset = CGPointMake([self contentOffset].x - [self bounds].size.width, [self contentOffset].y);
            [self setContentOffset:newOffset animated:TRUE];
            [self setIndex:newIndex notify:FALSE];
        } else if (realOffset > 0) {
            _afterTransitionIndex = newIndex;
            [self notifyInternalDelegateOfShowView:_rightView forIndex:newIndex];
            [self moveToState:PXInfiniteContentInternalFinishingTransitionState];
            CGPoint newOffset = CGPointMake([self contentOffset].x + [self bounds].size.width, [self contentOffset].y);
            [self setContentOffset:newOffset animated:TRUE];
            [self setIndex:newIndex notify:FALSE];
        }
    }
}

#pragma mark UIGestureRecognizerDelegate Methods
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer == [self panGestureRecognizer]) {
        CGPoint velocity = [[self panGestureRecognizer] velocityInView:self];
        BOOL allowed = _state == PXInfiniteContentInternalNotMovingState && fabs(velocity.x) > fabs(velocity.y);
        if (allowed) {
            [self notifyInternalDelegateOfShowView:_leftView forIndex:_index-1];
            [self notifyInternalDelegateOfShowView:_rightView forIndex:_index+1];
        }
        return allowed;
    }

    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return gestureRecognizer == [self panGestureRecognizer] && ![[self gestureRecognizers] containsObject:otherGestureRecognizer];
}

#pragma mark UIScrollViewDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView*)scrollView {
    NSAssert([scrollView contentOffset].y == 0.0, @"Non-zero y offset in PXInfiniteContentView - this may be caused by not calling setting automaticallyAdjustsScrollViewInsets to FALSE in a containing view controller");
}

- (void) scrollViewWillBeginDragging:(UIScrollView*)scrollView {
    if (_state == PXInfiniteContentInternalNotMovingState) {
        [self moveToState:PXInfiniteContentInternalScrollingState];
    }
}

- (void) scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    if (_state == PXInfiniteContentInternalScrollingState) {
        [self moveToState:decelerate ? PXInfiniteContentInternalFinishingTransitionState : PXInfiniteContentInternalNotMovingState];
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
    if (_state == PXInfiniteContentInternalFinishingTransitionState) {
        [self moveToState:PXInfiniteContentInternalNotMovingState];
    }
}

- (void) scrollViewDidEndScrollingAnimation:(UIScrollView*)scrollView {
    if (_state == PXInfiniteContentInternalFinishingTransitionState) {
        [self moveToState:PXInfiniteContentInternalNotMovingState];
    }
}

@end
