//
//  RootViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/14/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

protocol LoginControllerDelegate {
    func loginWithCredentials(username: String, password: String) -> ()
}

class RootViewController: UIViewController, LoginControllerDelegate {
    
    var loginController: LoginViewController!
    var appHomeController: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        alertsManager.parentController = self
        loadLoginController()
        // Do any additional setup after loading the view.
    }
    
    func loadLoginController() -> () {
        self.loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login") as? LoginViewController
        self.loginController.delegate = self
        
        self.addChildViewController(self.loginController)
        self.view.addSubview(self.loginController.view)
        self.loginController.didMove(toParentViewController: self)
    }
    
    func loginWithCredentials(username: String, password: String) -> () {
        //Login here
        if !username.isEmpty && !password.isEmpty {
            //if network is reachable
            ServiceManager.shared.login(with: username, and: password) { (data, error, stat) in
                DispatchQueue.main.async {
                    self.loginController.activityIndicator.stopAnimating()
                }
                if let stat = stat, stat == 200,
                    let resp = data as? [String: AnyObject],
                    let token = resp["id"] as? String {
                    //success
                    currentUser = User(username, token)
                    self.loginSuccess()
                }
                else{
                    DispatchQueue.main.async {
                        self.loginController.signInButton.isUserInteractionEnabled = true
                        alertsManager.presentInformationAlert("Login unsuccessful", title: "Login Failure")
                    }                    
                }
            }
        }
        else {
            alertsManager.presentInformationAlert("Enter the credentials", title: "Defaulted")
        }
    }
    
    /*func loginWithCredentials(username username: String, password: String) -> () {
        
        serviceManager.fetchRequest("/Logins/\(username)"){ (data, error) in
            if let error = error {
                print("ERROR ::: \(error)")
                alertsManager.presentInformationAlert("Desc: \(error.localizedDescription)", title: "Server Error")
            }
            else if error == nil && data == nil
            {
                alertsManager.presentInformationAlert("Invalid credentials Supplied", title: "Login Failure")
            }
            else
            {
                let dict = data as! [String:String]
                if dict["password"] != password
                {
                    alertsManager.presentInformationAlert("Invalid credentials Supplied", title: "Login Failure")
                }
                else
                {
                    loggedInUser = username
                    self.loginSuccess()
                }
            }
        }
        
    }*/
    
    func loginSuccess() -> () {
        //let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        /*DataController.initializeCoreData() {success, error in
            if !success
            {
                alertsManager.presentInformationAlert(error!, title: "Network Error")
            }
            else
         {*/
        //addAnimation        
        DispatchQueue.main.async {
            let indicator = BlockingUIIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            ServiceManager.shared.performInitialSyncOperation(with: indicator)
            self.loginController.activityIndicator.stopAnimating()
            self.appHomeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RootNavigation")
            
            //self.dismissViewControllerAnimated(false, completion: nil)
            self.loginController.dismiss(animated: false) { }
            self.appHomeController.view.blockUIWithActivityIndicator(indicator)
            self.present(self.appHomeController, animated: true, completion: nil)
        }
        
                //self.transitionFromViewController(self.loginController, toController: self.appHomeController, options: .CurveEaseIn)
                
                //self.transitionFromViewController(self.loginController, toViewController: self.appHomeController!, duration: 0.5, options: .CurveEaseIn, animations: nil, completion: nil)
                //self.presentViewController(rootController, animated: true, completion: nil)

            //}
        //}
        
    }
    
    
    fileprivate func transitionFromViewController(_ fromController: UIViewController, toController: UIViewController, options: UIViewAnimationOptions) {
        toController.view.frame = fromController.view.bounds
        self.addChildViewController(toController)
        fromController.willMove(toParentViewController: nil)
        
        self.view.addSubview(toController.view)
        
        UIView.transition(from: fromController.view, to: toController.view, duration: 0.5, options: options, completion: { (finished) -> Void in
            toController.didMove(toParentViewController: self)
            
            fromController.removeFromParentViewController()
            fromController.view.removeFromSuperview()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
