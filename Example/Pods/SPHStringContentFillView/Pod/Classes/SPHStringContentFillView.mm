//
//  SPHStringContentFillView.mm
//  SPHStringContentFillView
//
//  Created by Spencer Phippen on 2015/09/21.
//  Copyright (c) 2015年 Spencer Phippen. All rights reserved.
//

#import "SPHStringContentFillView.h"

#include <list>
#include <vector>
#include <cmath>
#include <unordered_set>
#include <utility>
#include <iostream>

namespace {

double randomDouble() {
    return arc4random() / static_cast<double>(UINT32_MAX);
}

// http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
void generatePositions(int hint, CGFloat width_, CGFloat height_, std::vector<CGPoint>& points, double& radius_) {
    hint *= 2;
    const double width = width_;
    const double height = height_;
    
    if (width == 0.0 || height == 0.0) {
        points.clear();
        radius_ = 1.0;
        return;
    }
    
    const double radius = std::sqrt(2.0 * width * height / hint);
    const double radiusSquared = radius*radius;
    const double cellSize = radius / std::sqrt(2.0);
    const int nCols = ceil(width / cellSize);
    const int nRows = ceil(height / cellSize);
    const int k = 300;

    std::vector<int> grid(nRows * nCols, -1);
    auto idxFromPt = [&](CGPoint p) -> int {
        const int col = static_cast<int>(std::floor(p.x / cellSize));
        const int row = static_cast<int>(std::floor(p.y / cellSize));
        const int idx = row * nCols + col;
        NSCAssert(idx >= 0 && idx < (nRows * nCols), @"Invalid index generated");
        return idx;
    };
    
    auto validSpace = [&](CGPoint p, int& pIndex) -> bool {
        const BOOL xInside = p.x >= 0 && p.x <= width;
        const BOOL yInside = p.y >= 0 && p.y <= height;
        if (!(xInside && yInside))
            return false;
        
        const static int possibleNeighbors[13][2] = {
            {0, 2},
            {-1, 1},
            {0, 1},
            {1, 1},
            {-2, 0},
            {-1, 0},
            {0, 0},
            {1, 0},
            {-2, 0},
            {-1, -1},
            {0, -1},
            {1, -1},
            {0, -2}
        };
        
        const int pIdx = idxFromPt(p);
        pIndex = pIdx;
        const int thisCoord[2] = {pIdx % nCols, pIdx / nCols};
        for (auto coord : possibleNeighbors) {
            const int newCoord[2] = {thisCoord[0] + coord[0], thisCoord[1] + coord[1]};
            const BOOL hasNeighbor = (newCoord[0] >= 0) && (newCoord[0] <= (nCols - 1)) &&
                               (newCoord[1] >= 0) && (newCoord[1] <= (nRows - 1));
            if (!hasNeighbor)
                continue;
            
            const int gridIndex = newCoord[1]*nCols + newCoord[0];
            int gridValue = grid[gridIndex];
            if (gridValue != -1) {
                CGPoint neighbor = points[gridValue];
                double distSquared = (p.x-neighbor.x)*(p.x-neighbor.x) + (p.y-neighbor.y)*(p.y-neighbor.y);
                if (distSquared < radiusSquared)
                    return false;
            }
        }
        
        return true;
    };
    
    const BOOL validStart = points.size() == 1 && (points[0].x >= 0 && points[0].x <= width && points[0].y >= 0 && points[0].y <= height);
    if (!validStart) {
        points.clear();
        const CGPoint start = CGPointMake(randomDouble() * width, randomDouble() * height);
        points.push_back(start);
    }

    const int startIdx = idxFromPt(points[0]);
    grid[startIdx] = 0;
    
    std::list<int> activeList(1, 0);
    while (activeList.size() > 0) {
        const int pointsIdx = *activeList.begin();
        const CGPoint fromHere = points[pointsIdx];
        
        CGPoint next;
        int nextGridIdx = 0;
        bool found = false;
        for (int i = 0; i < k; i++) {
            const double inner = radiusSquared;
            const double outer = 4.0*radiusSquared;
            const double r = std::sqrt(randomDouble()*(outer-inner) + inner);
            const double angle = randomDouble()*2.0*M_PI;
            
            next.x = fromHere.x + (r * std::cos(angle));
            next.y = fromHere.y + (r * std::sin(angle));
            
            if (!validSpace(next, nextGridIdx))
                continue;
            
            found = true;
            break;
        }

        if (!found) {
            activeList.erase(activeList.begin());
        } else {
            points.push_back(next);
            int nextIdx = static_cast<int>(points.size() - 1);
            NSCAssert(grid[nextGridIdx] == -1, @"Already filled cell...?");
            grid[nextGridIdx] = nextIdx;
            activeList.push_back(nextIdx);
        }
    }

    radius_ = radius;
}

void drawWithRotation(CGContextRef context, double angle, CGPoint center, void (^drawingBlock)()) {
    if (!drawingBlock)
        return;

    CGContextSaveGState(context);
    CGContextTranslateCTM(context, center.x, center.y);
    CGContextRotateCTM(context, angle);
    CGContextTranslateCTM(context, -center.x, -center.y);
    
    drawingBlock();
    CGContextRestoreGState(context);
}

}

@implementation SPHStringContentFillView {
    std::vector<CGPoint> _points;
    std::vector<CGFloat> _rotations;
    int _fillStep;
    int _fillStepCount;
    
    int _lastDrawFillStep;
    CGLayerRef _drawLayer;

    double _pointRadius;
    CGRect _boundsAtGenerationTime;
    int _generationHint;

    UIFont* _drawFont;
    NSTimer* _incrementTimer;
}

#pragma mark Constructors
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    _boundsAtGenerationTime = CGRectZero;
    
    _contentString = @"Content";
    _minimumFill = 10;
    _maximumFill = 100;
    _overlapFactor = 1.5;

    [self setContentMode:UIViewContentModeRedraw];

    return self;
}

#pragma mark UIView Methods
- (void) drawRect:(CGRect)rect {
    if (!CGRectEqualToRect([self bounds], _boundsAtGenerationTime)) {
        [self generateWithClear:TRUE];
        [self incrementWithNeedsDisplay:FALSE];
    }
    
    if (!_drawLayer) {
        const CGFloat scale = [self contentScaleFactor];
        const CGSize size = CGSizeMake([self bounds].size.width * scale, [self bounds].size.height * scale);
        _drawLayer = CGLayerCreateWithContext(UIGraphicsGetCurrentContext(), size, NULL);
        CGContextRef drawContext = CGLayerGetContext(_drawLayer);
        CGContextScaleCTM(drawContext, scale, scale);
    }
    
    if (_lastDrawFillStep < _fillStep) {
        NSString* text = _contentString;

        const NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
        if (!_drawFont) {
            const CGFloat idealSize = _pointRadius * _overlapFactor;
            CGFloat lo = 1.0;
            CGFloat hi = 200.0;
            while (std::abs(lo - hi) > 1.1) {
                const CGFloat test = ceil((lo + hi) / 2.0);
                NSDictionary* attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:test] };
                const CGSize size = [text boundingRectWithSize:[self bounds].size options:options attributes:attributes context:nil].size;
                const CGFloat maxDim = std::max(size.width, size.height);
                if (maxDim > idealSize)
                    hi = test;
                else if (maxDim < idealSize)
                    lo = test;
            }
            _drawFont = [UIFont systemFontOfSize:lo];
        }
        
        NSDictionary* attributes = @{ NSFontAttributeName : _drawFont };
        const CGSize drawSize = [text boundingRectWithSize:[self bounds].size options:options attributes:attributes context:nil].size;
        
        auto calculateDrawCount = [&](int fillStep) -> int {
            if (fillStep >= 0)
                return static_cast<int>(std::round((static_cast<double>(fillStep) / _fillStepCount) * _points.size()));
            else
                return 0;
        };

        const int previousDrawCount = calculateDrawCount(_lastDrawFillStep);
        const int drawCount = calculateDrawCount(_fillStep);
        NSCAssert(drawCount <= _points.size(), @"Invalid draw count");

        for (int i = previousDrawCount; i < drawCount; i++) {
            CGPoint p = _points[i];
            CGFloat rotation = _rotations[i];
            const CGRect drawInside = CGRectMake(p.x - drawSize.width*0.5, p.y - drawSize.height*0.5, drawSize.width, drawSize.height);
            
            CGContextRef drawContext = CGLayerGetContext(_drawLayer);
            UIGraphicsPushContext(drawContext);
            drawWithRotation(drawContext, rotation, p, ^{
                [text drawWithRect:drawInside options:options attributes:attributes context:nil];
            });
            UIGraphicsPopContext();
        }
        
        _lastDrawFillStep = _fillStep;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextDrawLayerInRect(ctx, [self bounds], _drawLayer);
}

#pragma mark Properties
- (void) setContentString:(NSString*)contentString {
    _contentString = [contentString copy];
    [self resetDrawState];
    [self increment];
}

- (void) setOverlapFactor:(double)overlapFactor {
    _overlapFactor = overlapFactor;
    [self resetDrawState];
    [self increment];
}

- (void) setMinimumFill:(int)minimumFill {
    _minimumFill = minimumFill;
    if (_maximumFill < _minimumFill)
        _maximumFill = _minimumFill;
    
    [self generateWithClear:TRUE];
    [self increment];
}

- (void) setMaximumFill:(int)maximumFill {
    _maximumFill = maximumFill;
    if (_minimumFill > _maximumFill)
        _minimumFill = _maximumFill;
    
    [self generateWithClear:TRUE];
    [self increment];
}

#pragma mark SPHStringContentFillView Methods
- (void) resetDrawState {
    _drawFont = nil;
    if (_drawLayer) {
        CGLayerRelease(_drawLayer);
        _drawLayer = NULL;
    }
    _lastDrawFillStep = -1;
    _fillStep = 0;

    [_incrementTimer invalidate];
    _incrementTimer = nil;
}

- (void) generateWithClear:(BOOL)clear {
    [self resetDrawState];

    _generationHint = arc4random_uniform(_maximumFill - _minimumFill + 1) + _minimumFill;
    _boundsAtGenerationTime = [self bounds];
    if (clear)
        _points.clear();
    generatePositions(_generationHint, _boundsAtGenerationTime.size.width, _boundsAtGenerationTime.size.height, _points, _pointRadius);
    _rotations.resize(_points.size());
    for (int i = 0; i < _rotations.size(); i++)
        _rotations[i] = randomDouble() * 2 * M_PI;

    _fillStepCount = std::min(100, static_cast<int>(_points.size()));
}

- (void) increment {
    [self incrementWithNeedsDisplay:TRUE];
}

- (void) incrementWithNeedsDisplay:(BOOL)needsDisplay {
    _fillStep++;
    if (needsDisplay)
        [self setNeedsDisplay];
    
    if (_fillStep < _fillStepCount) {
        const NSTimeInterval delayTime = 0.5 / _fillStepCount;
        _incrementTimer = [NSTimer scheduledTimerWithTimeInterval:delayTime target:self selector:@selector(increment) userInfo:nil repeats:FALSE];
    } else {
        _incrementTimer = nil;
    }
}

- (void) regenerate {
    [self generateWithClear:TRUE];
    [self increment];
}

- (void) regenerateFromPoint:(CGPoint)point {
    if (CGRectContainsPoint([self bounds], point)) {
        _points.clear();
        _points.push_back(point);
        [self generateWithClear:FALSE];
        [self increment];
    }
}

@end
