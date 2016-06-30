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
- (void) infiniteContentView:(PXInfiniteContentView*)infiniteContentView transitionedToIndex:(int)index;
/**
 * Called when a view is about to become visible for the given index (including partway through a still-occuring user-initiated scroll).
 */
- (void) infiniteContentView:(PXInfiniteContentView*)infiniteContentView willShowView:(id)view forIndex:(int)index;
@end

/**
 * Due to iOS silliness you may need to call [vc setAutomaticallyAdjustsScrollViewInsets:FALSE]
 * on view controllers containing this view (sometimes multiple levels up, if container view controllers
 * are used) in order for it to behave properly.
 */
@interface PXInfiniteContentView : UIView

- (instancetype) init __attribute__((unavailable("Use one of the other init methods")));
- (instancetype) initWithFrame:(CGRect)frame __attribute__((unavailable("Use one of the other init methods")));
- (instancetype) initWithViewClass:(Class)class;

@property (nonatomic, weak) id<PXInfiniteContentViewDelegate> delegate;

@property (nonatomic) id leftView;
@property (nonatomic) id centerView;
@property (nonatomic) id rightView;

/** If the view is currently scrolling, the index change will not take effect until the transition is complete. */
@property (nonatomic) int index;
/**
 * If the view is currently scrolling, the index change will not take effect until the transition is complete.
 * The index property will be clamped to these bounds when the change takes effect (whether immediately or after the current transition).
 */
@property (nonatomic) PXPageIndexBounds* contentBounds;

/** If TRUE, the view will "bounce" (like the UIScrollView bounces property) on the left/right boundaries. Defaults to FALSE. */
@property (nonatomic) BOOL bouncesAtBoundaries;

/**
 * Animates a change to the current index + offset.
 * No animation occurs if offset is 0.
 * Otherwise, the animation occurs like a normal transition in the direction of the offset, but the view that appears will be
 * associated with the index at the given offset.
 */
- (void) animateChangeWithOffset:(int)offset;

@end
