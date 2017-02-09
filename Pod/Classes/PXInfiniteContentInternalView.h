//
//  PXInfiniteContentInternalView.h
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/19.
//
//

#import <UIKit/UIKit.h>
#import "PXPageIndexBounds.h"

@class PXInfiniteContentInternalView;

@protocol PXInfiniteContentInternalViewDelegate <NSObject>
- (void) internalInfiniteContentView:(PXInfiniteContentInternalView* _Nonnull)infiniteContentView transitionedToIndex:(int)index;
- (void) internalInfiniteContentView:(PXInfiniteContentInternalView* _Nonnull)infiniteContentView willShowView:(UIView * _Nonnull)view forIndex:(int)index;
@end

@interface PXInfiniteContentInternalView : UIScrollView

- (instancetype _Nonnull) init __attribute__((unavailable("Use one of the other init methods")));
- (instancetype _Nonnull) initWithFrame:(CGRect)frame __attribute__((unavailable("Use one of the other init methods")));

- (instancetype _Nonnull) initWithLeftView:(UIView * _Nonnull)leftView centerView:(UIView * _Nonnull)centerView rightView:(UIView * _Nonnull)rightView;

@property (weak, nullable) id<PXInfiniteContentInternalViewDelegate> internalDelegate;

@property (nonatomic, nonnull) UIView* leftView;
@property (nonatomic, nonnull) UIView* centerView;
@property (nonatomic, nonnull) UIView* rightView;
@property (nonatomic) BOOL shouldBeRequiredToFailByGestureRecognizers;
@property (nonatomic) int index;
@property (nonatomic, nonnull) PXPageIndexBounds* pageIndexBounds;
@property (nonatomic) CGFloat pagingVelocityThreshold;

@property (nonatomic) BOOL bouncesAtBoundaries;

- (void) animateChangeWithOffset:(int)offset;

- (void)reloadData;

@end
