//
//  UIViewController+PXBelowStatusBarView.m
//  PXBelowStatusBarView
//
//  Created by Spencer Phippen on 2015/09/16.
//
//

#import "PXBelowStatusBarView.h"
#import <objc/runtime.h>

@interface PXBelowStatusBarView (Private)
@property (nonatomic,weak) UIViewController* container;
@end


static void* swizzly(Class class, SEL sel, IMP newImp) {
    if (!sel || !newImp)
        return NULL;
    
    Method m = class_getInstanceMethod(class, sel);
    if (!m)
        return NULL;
    
    const char* typeEncoding = method_getTypeEncoding(m);
    if (!typeEncoding)
        return NULL;
    
    return (void*)class_replaceMethod(class, sel, newImp, typeEncoding);
}

void (*setView_orig)(id __unsafe_unretained, SEL, UIView*);
static void PXBelowStatusBarView_SetView(id __unsafe_unretained self, SEL _cmd, UIView* view) {
    if ([view isKindOfClass:[PXBelowStatusBarView class]]) {
        PXBelowStatusBarView* belowBarView = (PXBelowStatusBarView*)view;
        [belowBarView setContainer:self];
    }
    
    setView_orig(self, _cmd, view);
}

@interface UIViewController (PXBelowStatusBarView)
@end

@implementation UIViewController (PXBelowStatusBarView)
+ (void) load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        setView_orig = swizzly([UIViewController class], @selector(setView:), (IMP)PXBelowStatusBarView_SetView);
    });
}

@end
