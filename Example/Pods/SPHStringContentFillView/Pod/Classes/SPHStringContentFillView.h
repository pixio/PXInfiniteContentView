//
//  SPHStringContentFillView.h
//  SPHStringContentFillView
//
//  Created by Spencer Phippen on 2015/09/21.
//  Copyright (c) 2015年 Spencer Phippen. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Fills itself with randomly placed and oriented copies of a string.
 * The view state (positions/rotations) is regenerated automatically whenever its bounds change.
 */
@interface SPHStringContentFillView : UIView

/**
 * The string used to fill the view. Default value is @"Content".
 * Changing this property does not cause regeneration.
 */
@property (nonatomic,copy) NSString* contentString;

/**
 * The "minimum number" of copies of the string to fill with.
 * In quotes because the actual figure may be a little less than this - it's really a suggestion.
 * Default value is 10.
 * When changed, regeneration is forced.
 */
@property (nonatomic) int minimumFill;

/**
 * The "maximum number" of copies of the string to fill with.
 * In quotes because the actual figure may be a little more than this - it's really a suggestion.
 * Default value is 100.
 * When changed, regeneration is forced.
 */
@property (nonatomic) int maximumFill;

/**
 * A constant used to size the text that is displayed.
 * At 1.0, strings do not overlap (they barely touch).
 * At lower values, text gets smaller (less overlap).
 * At higher values, text gets bigger (more overlap).
 * Default value is 1.5.
 * Changing this property does not cause regeneration.
 */
@property (nonatomic) double overlapFactor;

/** Makes the view regenerate all its positions/orientations. */
- (void) regenerate;

/** Makes the view regenerate all its positions/orientations, starting with the given one.
    @param point The first point to include. If it's not inside this view's bounds, the call is ignored. */
- (void) regenerateFromPoint:(CGPoint)point;

@end
