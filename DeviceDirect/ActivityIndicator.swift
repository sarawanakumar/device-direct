//
//  ActivityIndicator.swift
//  DeviceDirect
//
//  Created by Niranjana Devi on 10/11/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import UIKit

class BlockingUIIndicatorView: UIActivityIndicatorView {
    deinit {
        let window = UIApplication.shared.windows[0]
        window.isUserInteractionEnabled = true
    }
    
    override func startAnimating() {
        super.startAnimating()
        let window = UIApplication.shared.windows[0]
        window.backgroundColor = UIColor.gray
        window.isUserInteractionEnabled = false
    }
    
    override func stopAnimating() {
        super.stopAnimating()
        let window = UIApplication.shared.windows[0]
        window.isUserInteractionEnabled = true
    }
}


extension UIViewController {
    func waitForBlock(_ block:(_ activity:UIActivityIndicatorView)->()) {
        self.view.waitForBlock(block)
    }
}

extension UIView {
    func waitForBlock(_ block:(_ activity:UIActivityIndicatorView)->()) {
        let activity = BlockingUIIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activity.bounds.size = CGSize(width: 20.0, height: 20.0)
        activity.center = self.center

        self.addSubview(activity)
        activity.startAnimating()
        
        block(activity)
    }
    
    func blockUIWithActivityIndicator(_ activity: BlockingUIIndicatorView) {
        activity.bounds.size = CGSize(width: 20.0, height: 20.0)
        activity.center = self.center
        self.addSubview(activity)
        activity.startAnimating()
    }
}
