//
//  LoginViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/14/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var delegate: LoginControllerDelegate?
    @IBOutlet weak var userNameField: LoginTextField!
    
    @IBOutlet weak var passwordField: LoginTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var viewTapRecognizer: UITapGestureRecognizer!

    @IBAction func viewTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(viewTapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = true
        signInButton.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInTapped(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()        
        delegate?.loginWithCredentials(username: userNameField.text!, password: passwordField.text!)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
