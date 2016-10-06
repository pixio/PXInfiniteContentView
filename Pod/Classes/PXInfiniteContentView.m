//
//  PXInfiniteContentView.m
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/18.
//
//

#import "PXInfiniteContentView.h"

#import "PXInfiniteContentInternalView.h"

@interface PXInfiniteContentView () <UIGestureRecognizerDelegate, PXInfiniteContentInternalViewDelegate>
@end

@implementation PXInfiniteContentView {
    PXInfiniteContentInternalView* _scroll;
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

- (instancetype) initWithViewClass:(Class)class {
    id leftView = [[class alloc] initWithFrame:CGRectZero];
    id centerView = [[class alloc] initWithFrame:CGRectZero];
    id rightView = [[class alloc] initWithFrame:CGRectZero];
    
    return [self initWithLeftView:leftView centerView:centerView rightView:rightView];
}

- (instancetype) initWithLeftView:(id)leftView centerView:(id)centerView rightView:(id)rightView {
    PXInfiniteContentInternalView* scroll = [[PXInfiniteContentInternalView alloc] initWithLeftView:leftView centerView:centerView rightView:rightView];
    if (!scroll)
        return nil;

    self = [super initWithFrame:CGRectZero];
    if (!self)
        return nil;

    _scroll = scroll;
    [_scroll setInternalDelegate:self];
    [self setBouncesAtBoundaries:FALSE];
    [self addSubview:_scroll];
    
    return self;
}

#pragma mark Properties
- (void) setDelegate:(id<PXInfiniteContentViewDelegate>)delegate {
    _delegate = delegate;

    [self notifyDelegateOfTransitionToIndex:[_scroll index]];
    [self notifyDelegateOfShowView:[self centerView] forIndex:[self index]];
}

- (id) leftView {
    return [_scroll leftView];
}

- (void) setLeftView:(id)leftView {
    [_scroll setLeftView:leftView];
}

- (id) centerView {
    return [_scroll centerView];
}

- (void) setCenterView:(id)centerView {
    [_scroll setCenterView:centerView];
}

- (id) rightView {
    return [_scroll rightView];
}

- (void) setRightView:(id)rightView {
    [_scroll setRightView:rightView];
}

- (int) index {
    return [_scroll index];
}

- (void) setIndex:(int)index {
    [_scroll setIndex:index];
}

- (PXPageIndexBounds*) pageIndexBounds {
    return [_scroll pageIndexBounds];
}

- (void) setPageIndexBounds:(PXPageIndexBounds*)pageIndexBounds {
    [_scroll setPageIndexBounds:pageIndexBounds];
}

- (BOOL) bouncesAtBoundaries {
    return [_scroll bouncesAtBoundaries];
}

- (void) setBounces:(BOOL)bounces {
    [_scroll setBouncesAtBoundaries:bounces];
}

- (BOOL) shouldBeRequiredToFailByGestureRecognizers
{
    return [_scroll shouldBeRequiredToFailByGestureRecognizers];
}

-(void) setShouldBeRequiredToFailByGestureRecognizers:(BOOL)shouldBeRequiredToFailByGestureRecognizers
{
    [_scroll setShouldBeRequiredToFailByGestureRecognizers:shouldBeRequiredToFailByGestureRecognizers];
}

-(void)setPagingVelocityThreshold:(CGFloat)pagingVelocityThreshold
{
    [_scroll setPagingVelocityThreshold:pagingVelocityThreshold];
}
-(CGFloat)pagingVelocityThreshold
{
    return [_scroll pagingVelocityThreshold];
}
#pragma mark UIView Methods
- (void) layoutSubviews {
    [super layoutSubviews];
    [_scroll setFrame:[self bounds]];
}

#pragma mark PXInfiniteContentView Methods
- (void) animateChangeWithOffset:(int)offset {
    [_scroll animateChangeWithOffset:offset];
}

- (void) notifyDelegateOfTransitionToIndex:(int)index {
    if (_delegate && [_delegate respondsToSelector:@selector(infiniteContentView:transitionedToIndex:)])
        [_delegate infiniteContentView:self transitionedToIndex:index];
}

- (void) notifyDelegateOfShowView:(id)view forIndex:(int)index {
    if (_delegate && [_delegate respondsToSelector:@selector(infiniteContentView:willShowView:forIndex:)])
        [_delegate infiniteContentView:self willShowView:view forIndex:index];
}

- (void)reloadData
{
    [_scroll reloadData];
}

#pragma mark PXInfiniteContentInternalViewDelegate Methods
- (void) internalInfiniteContentView:(PXInfiniteContentInternalView*)infiniteContentView transitionedToIndex:(int)index {
    [self notifyDelegateOfTransitionToIndex:index];
}

- (void) internalInfiniteContentView:(PXInfiniteContentInternalView*)infiniteContentView willShowView:(id)view forIndex:(int)index {
    [self notifyDelegateOfShowView:view forIndex:index];
}

@end
