//
//  PXInfiniteContentBounds.h
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/20.
//
//

#import <Foundation/Foundation.h>

@interface PXInfiniteContentBounds : NSObject

- (instancetype) init __attribute__((unavailable("Use one of the other init methods")));

+ (instancetype) noBounds;
+ (instancetype) lowerBound:(int)lowerBound;
+ (instancetype) upperBound:(int)upperBound;
/** lowerBound must be less than or equal to upperBound */
+ (instancetype) lowerBound:(int)lowerBound upperBound:(int)upperBound;

@property () BOOL hasLowerBound;
@property () int lowerBound;

@property () BOOL hasUpperBound;
@property () int upperBound;

- (int) clampValue:(int)value;

@end
