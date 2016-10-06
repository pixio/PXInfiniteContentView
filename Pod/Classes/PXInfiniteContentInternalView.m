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
    PXPageIndexBounds* _afterTransitionBounds;
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
    _pageIndexBounds = [PXPageIndexBounds noBounds];
    _afterTransitionBounds = [PXPageIndexBounds noBounds];
    
    [self setDelaysContentTouches:FALSE];
    [self setShowsHorizontalScrollIndicator:FALSE];
    [self setShowsVerticalScrollIndicator:FALSE];
    [self setPagingEnabled:TRUE];
    [self setDirectionalLockEnabled:TRUE];
    [self setPagingVelocityThreshold:0.0];
    
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
        _index = [_pageIndexBounds clampValue:index];
        if (_index != oldIndex && notify) {
            [self notifyInternalDelegateOfTransitionToIndex:_index];
            [self notifyInternalDelegateOfShowView:_leftView forIndex:_index - 1];
            [self notifyInternalDelegateOfShowView:_centerView forIndex:_index];
            [self notifyInternalDelegateOfShowView:_rightView forIndex:_index + 1];
        }
        [self setNeedsLayout];
        [self layoutIfNeeded];
    } else {
        _hasAfterTransitionIndex = TRUE;
        _afterTransitionIndex = index;
    }
}

- (void) setPageIndexBounds:(PXPageIndexBounds*)pageIndexBounds {
    NSParameterAssert(pageIndexBounds);
    if (_state == PXInfiniteContentInternalNotMovingState) {
        _pageIndexBounds = pageIndexBounds;
        _index = [_pageIndexBounds clampValue:_index];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    _afterTransitionBounds = _pageIndexBounds;
}

- (BOOL) bouncesAtBoundaries {
    return [self bounces];
}

- (void) setBouncesAtBoundaries:(BOOL)bouncesAtBoundaries {
    [self setBounces:bouncesAtBoundaries];
    [self setNeedsLayout];
}

- (void) notifyInternalDelegateOfTransitionToIndex:(int)index {
    if (_internalDelegate)
        [_internalDelegate internalInfiniteContentView:self transitionedToIndex:index];
}

- (void) notifyInternalDelegateOfShowView:(id)view forIndex:(int)index {
    if ([_pageIndexBounds clampValue:index] != index) {
        return;
    }
    
    if (_internalDelegate)
        [_internalDelegate internalInfiniteContentView:self willShowView:view forIndex:index];
}

#pragma mark UIView Methods
- (void) layoutSubviews {
    [super layoutSubviews];
    
    BOOL onLowerBoundary = [_pageIndexBounds hasLowerBound] && _index == [_pageIndexBounds lowerBound];
    BOOL onUpperBoundary = [_pageIndexBounds hasUpperBound] && _index == [_pageIndexBounds upperBound];
    
    [_leftView setHidden:[self bouncesAtBoundaries] && onLowerBoundary];
    [_rightView setHidden:[self bouncesAtBoundaries] && onUpperBoundary];
    
    int sizeMultiplier = 3 - (!!onLowerBoundary) - (!!onUpperBoundary);
    const CGRect entireArea = [self bounds];
    const CGSize contentSize = CGSizeMake(entireArea.size.width * sizeMultiplier, entireArea.size.height);
    [self setContentSize:contentSize];
    
    const CGFloat xOffset = (onLowerBoundary ? -entireArea.size.width : 0);
    CGRect leftArea = CGRectMake(xOffset, 0, entireArea.size.width, entireArea.size.height);
    CGRect centerArea = CGRectMake(xOffset + entireArea.size.width, 0, entireArea.size.width, entireArea.size.height);
    CGRect rightArea = CGRectMake(xOffset + 2 * entireArea.size.width, 0, entireArea.size.width, entireArea.size.height);
    
    if (_state == PXInfiniteContentInternalNotMovingState) {
        CGPoint desiredOffset;
        if (onLowerBoundary) {
            desiredOffset = CGPointMake(0, 0.0);
        } else {
            desiredOffset = CGPointMake(entireArea.size.width, 0.0);
        }
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
                BOOL onLowerBoundary = [_pageIndexBounds hasLowerBound] && _index == [_pageIndexBounds lowerBound];
                const CGFloat centerThreshold = (!onLowerBoundary ? [self bounds].size.width : 0);
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
            
            [self setPageIndexBounds:_afterTransitionBounds];
            if (_hasAfterTransitionIndex) {
                [self setIndex:_afterTransitionIndex notify:FALSE];
                _hasAfterTransitionIndex = FALSE;
            }
            [self notifyInternalDelegateOfTransitionToIndex:_index];
            
            [self notifyInternalDelegateOfShowView:_leftView forIndex:_index-1];
            [self notifyInternalDelegateOfShowView:_rightView forIndex:_index+1];
            
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
        const int newIndex = [_pageIndexBounds clampValue:_index + offset];
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

- (void)reloadData
{
    [self notifyInternalDelegateOfShowView:_leftView forIndex:_index - 1];
    [self notifyInternalDelegateOfShowView:_centerView forIndex:_index];
    [self notifyInternalDelegateOfShowView:_rightView forIndex:_index + 1];
}

#pragma mark UIGestureRecognizerDelegate Methods
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer == [self panGestureRecognizer]) {
        CGPoint velocity = [[self panGestureRecognizer] velocityInView:self];
        BOOL allowed = _state == PXInfiniteContentInternalNotMovingState && fabs(velocity.x) > fabs(velocity.y) * 3.0 && fabs(velocity.x) > _pagingVelocityThreshold;
        return allowed;
    }
    
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    return gestureRecognizer == [self panGestureRecognizer];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [self shouldBeRequiredToFailByGestureRecognizers];
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
