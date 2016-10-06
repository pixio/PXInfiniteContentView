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
- (void) internalInfiniteContentView:(PXInfiniteContentInternalView*)infiniteContentView transitionedToIndex:(int)index;
- (void) internalInfiniteContentView:(PXInfiniteContentInternalView*)infiniteContentView willShowView:(id)view forIndex:(int)index;
@end

@interface PXInfiniteContentInternalView : UIScrollView

- (instancetype) init __attribute__((unavailable("Use one of the other init methods")));
- (instancetype) initWithFrame:(CGRect)frame __attribute__((unavailable("Use one of the other init methods")));

- (instancetype) initWithLeftView:(id)leftView centerView:(id)centerView rightView:(id)rightView;

@property (weak) id<PXInfiniteContentInternalViewDelegate> internalDelegate;

@property (nonatomic) id leftView;
@property (nonatomic) id centerView;
@property (nonatomic) id rightView;
@property (nonatomic) BOOL shouldBeRequiredToFailByGestureRecognizers;
@property (nonatomic) int index;
@property (nonatomic) PXPageIndexBounds* pageIndexBounds;
@property (nonatomic) CGFloat pagingVelocityThreshold;

@property (nonatomic) BOOL bouncesAtBoundaries;

- (void) animateChangeWithOffset:(int)offset;

- (void)reloadData;

@end
