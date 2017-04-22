//
//  LoginTextField.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/18/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class LoginTextField: UITextField {

    var paddingTop:CGFloat = 11
    var paddingBottom:CGFloat = 11
    var paddingLeft:CGFloat = 20
    var paddingRight:CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func prepareForInterfaceBuilder() {
        initialize()
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsetsMake(paddingTop, paddingLeft, paddingBottom, paddingRight)
        let edges = UIEdgeInsetsInsetRect(bounds, padding)
        return super.textRect(forBounds: edges)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = UIEdgeInsetsMake(paddingTop, paddingLeft, paddingBottom, paddingRight)
        let edges = UIEdgeInsetsInsetRect(bounds, padding)
        return super.editingRect(forBounds: edges)
    }
    
    func initialize() {
        self.backgroundColor = UIColor(red:0.94, green:0.98, blue:0.99, alpha:1.0)
        self.layer.cornerRadius = 4.0
    }

}
