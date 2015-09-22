//
//  PXAppDelegate.m
//  PXInfiniteContentView
//
//  Created by Spencer Phippen on 09/21/2015.
//  Copyright (c) 2015 Spencer Phippen. All rights reserved.
//

#import "PXAppDelegate.h"

#import "PXViewController.h"

@implementation PXAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    UIWindow* win = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [win setRootViewController:[PXViewController new]];
    [self setWindow:win];
    [win makeKeyAndVisible];
    
    return TRUE;
}

@end
