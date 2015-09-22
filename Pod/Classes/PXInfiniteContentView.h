//
//  PXInfiniteContentView.h
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/18.
//
//

#import <UIKit/UIKit.h>
#import "PXInfiniteContentBounds.h"

@class PXInfiniteContentView;

@protocol PXInfiniteContentViewDelegate <NSObject>
@optional
- (void) infiniteContentView:(PXInfiniteContentView*)infiniteContentView transitionedToIndex:(int)index;
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
@property (nonatomic) PXInfiniteContentBounds* contentBounds;

- (void) animateChangeWithOffset:(int)offset;

@end
