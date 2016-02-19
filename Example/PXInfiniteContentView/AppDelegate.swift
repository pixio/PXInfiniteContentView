//
//  PXSwiftAppDelegate.swift
//  PXInfiniteContentView
//
//  Created by Dave Heyborne on 2.18.16.
//  Copyright © 2016 Spencer Phippen. All rights reserved.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let controller: ViewController = ViewController()
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {}
    
    func applicationDidEnterBackground(application: UIApplication) {}
    
    func applicationWillEnterForeground(application: UIApplication) {}
    
    func applicationDidBecomeActive(application: UIApplication) {}
    
    func applicationWillTerminate(application: UIApplication) {}
}
