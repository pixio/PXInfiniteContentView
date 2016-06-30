//
//  PXPageIndexBounds.m
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 2015/08/20.
//
//

#import "PXPageIndexBounds.h"

@implementation PXPageIndexBounds

- (instancetype) init {
    NSAssert(FALSE, @"Bad init function");
    return nil;
}

+ (instancetype) noBounds {
    return [[self alloc] initWithHasLowerBound:FALSE lowerBound:0 hasUpperBound:FALSE upperBound:0];
}

+ (instancetype) lowerBound:(int)lowerBound {
    return [[self alloc] initWithHasLowerBound:TRUE lowerBound:lowerBound hasUpperBound:FALSE upperBound:0];
}

+ (instancetype) upperBound:(int)upperBound {
    return [[self alloc] initWithHasLowerBound:FALSE lowerBound:0 hasUpperBound:TRUE upperBound:upperBound];
}

+ (instancetype) lowerBound:(int)lowerBound upperBound:(int)upperBound {
    NSParameterAssert(lowerBound <= upperBound);
    return [[self alloc] initWithHasLowerBound:TRUE lowerBound:lowerBound hasUpperBound:TRUE upperBound:upperBound];
}

- (instancetype) initWithHasLowerBound:(BOOL)hasLowerBound lowerBound:(int)lowerBound hasUpperBound:(BOOL)hasUpperBound upperBound:(int)upperBound {
    self = [super init];
    if (!self)
        return nil;
    
    _hasLowerBound = hasLowerBound;
    _lowerBound = lowerBound;
    
    _hasUpperBound = hasUpperBound;
    _upperBound = upperBound;
    
    return self;
}

- (int) clampValue:(int)value {
    if (_hasLowerBound && value < _lowerBound)
        return _lowerBound;
    if (_hasUpperBound && value > _upperBound)
        return _upperBound;
    else
        return value;
}

@end
