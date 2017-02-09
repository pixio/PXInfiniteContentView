//
//  PXInfiniteContentView.h
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/18.
//
//

#import <UIKit/UIKit.h>
#import "PXPageIndexBounds.h"

@class PXInfiniteContentView;

@protocol PXInfiniteContentViewDelegate <NSObject>
@optional
/**
 * Called when a transition completes - the center view post-transition is at the given index.
 */
- (void) infiniteContentView:(PXInfiniteContentView* _Nonnull)infiniteContentView transitionedToIndex:(int)index;
/**
 * Called when a view is about to become visible for the given index (including partway through a still-occuring user-initiated scroll).
 */
- (void) infiniteContentView:(PXInfiniteContentView* _Nonnull)infiniteContentView willShowView:(UIView* _Nonnull)view forIndex:(int)index;
@end

/**
 * Due to iOS silliness you may need to call [vc setAutomaticallyAdjustsScrollViewInsets:FALSE]
 * on view controllers containing this view (sometimes multiple levels up, if container view controllers
 * are used) in order for it to behave properly.
 */
@interface PXInfiniteContentView : UIView

- (instancetype _Nonnull) init __attribute__((unavailable("Use one of the other init methods")));
- (instancetype _Nonnull) initWithFrame:(CGRect)frame __attribute__((unavailable("Use one of the other init methods")));
- (instancetype _Nonnull) initWithViewClass:(Class _Nonnull)class;

@property (nonatomic, weak, nullable) id<PXInfiniteContentViewDelegate> delegate;

@property (nonatomic, nonnull) UIView* leftView;
@property (nonatomic, nonnull) UIView* centerView;
@property (nonatomic, nonnull) UIView* rightView;
@property (nonatomic) BOOL shouldBeRequiredToFailByGestureRecognizers;

/**
 Paging Velocity Threshold setts the swipe velocity required to start the gesture recognizer. This helps in keeping it more like a paged scrollview.
 */
@property (nonatomic) CGFloat pagingVelocityThreshold;

/** If the view is currently scrolling, the index change will not take effect until the transition is complete. */
@property (nonatomic) int index;
/**
 * If the view is currently scrolling, the index change will not take effect until the transition is complete.
 * The index property will be clamped to these bounds when the change takes effect (whether immediately or after the current transition).
 */
@property (nonatomic, nonnull) PXPageIndexBounds* pageIndexBounds;

/** If TRUE, the view will "bounce" (like the UIScrollView bounces property) on the left/right boundaries. Defaults to FALSE. */
@property (nonatomic) BOOL bouncesAtBoundaries;

/**
 *  Reload the center, left, and right content from the delegate.
 *  
 *  This view loads it's content when the delegate is set (initially) and when scrolling completes.
 *  If the data set changes between scrolls, make sure to call reloadData to properly prepare the left and right views.
 */
- (void)reloadData;

/**
 * Animates a change to the current index + offset.
 * No animation occurs if offset is 0.
 * Otherwise, the animation occurs like a normal transition in the direction of the offset, but the view that appears will be
 * associated with the index at the given offset.
 */
- (void) animateChangeWithOffset:(int)offset;

@end
