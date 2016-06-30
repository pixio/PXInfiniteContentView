//
//  PXPageIndexBounds.h
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/20.
//
//

#import <Foundation/Foundation.h>

/**
 *  An object representing the limit(s) of the page indices in either direction.
 *
 *  PXInfiniteContentView begins at index 0 and content bounds potentially limit
 *  the number of pages that can be displayed in either direction..
 */
@interface PXPageIndexBounds : NSObject

- (instancetype) init __attribute__((unavailable("Use one of the other init methods")));

/**
 *  Create a contentBounds with no bounds.
 */
+ (instancetype) noBounds;

/**
 *  Create a contentBounds with only a lower bound.  This only limits leftward swipes
 *
 *  @param lowerBound the lower bound.
 *
 *  @return a contentBounds with only a lower bound
 */
+ (instancetype) lowerBound:(int)lowerBound;

/**
 *  Create a contentBounds with only an upper bound.  This only limits rightward swipes
 *
 *  @param upperBound the upper bound.
 *
 *  @return a contentBounds with only an upper bound
 */
+ (instancetype) upperBound:(int)upperBound;

/**
 *  Create a contentBounds with lower and upper bounds, limiting scrolls in both directions.
 *
 *  Note that lowerBound must be less than or equal to upperBound.
 *
 *  @param lowerBound the lowest page index
 *  @param upperBound the hightest page index
 *
 *  @return a new contentBounds object
 */
+ (instancetype) lowerBound:(int)lowerBound upperBound:(int)upperBound;

@property () BOOL hasLowerBound;
@property () int lowerBound;

@property () BOOL hasUpperBound;
@property () int upperBound;

/**
 *  Clamp the passed value to within the content bounds.
 *
 *  @param value the value to be clamped
 *
 *  @return a value that has been clamped within the content bounds.
 */
- (int) clampValue:(int)value;

@end
