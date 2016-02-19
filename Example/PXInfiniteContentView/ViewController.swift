//
//  PXSwiftViewController.swift
//  PXInfiniteContentView
//
//  Created by Dave Heyborne on 2.18.16.
//  Copyright © 2016 Spencer Phippen. All rights reserved.
//

import UIKit
import PXBelowStatusBarView
import PXInfiniteContentView
import SPHStringContentFillView
import PXMultiForwarder

class ViewController: UIViewController, PXInfiniteContentViewDelegate {
    var infiniteContentView: PXInfiniteContentView {
        return (view as! PXBelowStatusBarView).containedView as! PXInfiniteContentView
    }
    
    var leftView: SPHStringContentFillView {
        return infiniteContentView.leftView as! SPHStringContentFillView
    }
    
    var centerView: SPHStringContentFillView {
        return infiniteContentView.centerView as! SPHStringContentFillView
    }
    
    var rightView: SPHStringContentFillView {
        return infiniteContentView.rightView as! SPHStringContentFillView
    }
    
    var allViews: SPHStringContentFillView {
        return (PXMultiForwarder(arrayOfObjects: [leftView, centerView, rightView]) as AnyObject) as! SPHStringContentFillView
    }
    
    override func loadView() {
        super.loadView()
        let belowStatusBarView: PXBelowStatusBarView = PXBelowStatusBarView()
        belowStatusBarView.backgroundColor = UIColor.whiteColor()
        
        let infiniteContentView: PXInfiniteContentView = PXInfiniteContentView(viewClass: SPHStringContentFillView.self)
        belowStatusBarView.containedView = infiniteContentView
        view = belowStatusBarView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infiniteContentView.delegate = self
        allViews.backgroundColor = UIColor.whiteColor()
    }
    
    func infiniteContentView(infiniteContentView: PXInfiniteContentView!, transitionedToIndex index: Int32) {
        allViews.regenerate()
    }
    
    func infiniteContentView(infiniteContentView: PXInfiniteContentView!, willShowView view: AnyObject!, forIndex index: Int32) {
        (view as! SPHStringContentFillView).contentString = "Content +\(index)"
    }
}
