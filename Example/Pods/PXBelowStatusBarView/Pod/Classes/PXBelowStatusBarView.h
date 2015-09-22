//
//  PXBelowStatusBarView.h
//  PXBelowStatusBarView
//
//  Created by Spencer Phippen on 2015/07/29.
//
//

#import <UIKit/UIKit.h>

/**
 * A view that resizes its contained view to be below (read: greater y value than) the status bar if it would
 * otherwise be covered by the status bar.
 */
@interface PXBelowStatusBarView : UIView

/**
 * The view contained in this one, which gets laid out so that it is directly below, but never "behind" the status bar.
 */
@property (nonatomic) UIView* containedView;

@end
