//
//  AlertManager.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/12/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import Foundation
import UIKit

protocol AlertManagerDelegate {
    func presentAlertWithMessage(_ message: String, title: String, okAction: ((_ action: UIAlertAction)->())?, cancelAction: ((_ action: UIAlertAction)->())?)
    func presentInformationAlert(_ message: String, title: String)
}

class AlertManager: NSObject {
    var alert: UIAlertController?
    weak var parentController: UIViewController?
    override init() {
        
    }
    
    //MARK: Delegate methods
    func presentActionAlert(_ message: String, title: String, okAction: (()->())?, cancelAction: (()->())?) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let onOk = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let action = okAction {
                action()
            }
        })
        let onCancel = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            if let action = cancelAction {
                action()
            }
        })
        
        alert?.addAction(onOk)
        alert?.addAction(onCancel)
        parentController?.present(alert!, animated: true, completion: {
            print("alert displayed")
        })
    }
    
    func presentInformationAlert(_ message: String, title: String, okAction: (()->())? = nil) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            if let action = okAction {
                action()
            }
        })
        alert?.addAction(okAction)
        parentController?.present(alert!, animated: true, completion: nil)
    }
    
    func presentLogoutAlert(_ message: String, title: String = "Error Occurred.") {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.parentController?.logoutUser()
        })
        alert?.addAction(okAction)
        parentController?.present(alert!, animated: true, completion: nil)
    }
}

class CustomAlert: UIAlertController {
    
}
