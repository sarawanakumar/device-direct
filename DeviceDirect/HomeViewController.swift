//
//  HomeViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/23/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var inUseButton: UIButton!
    @IBOutlet weak var availableButton: UIButton!
    @IBOutlet weak var inRepairButton: UIButton!
    @IBOutlet weak var inContractButton: UIButton!
    @IBOutlet weak var recentAccreditationsTable: UITableView!
    @IBOutlet weak var separatorView: UIView!
    
    //Data
    var inUseCount: Int?
    var availableCount: Int?
    var inRepairCount: Int?
    var inContractCount: Int?
    var recentAccreditations: [Accreditation]?
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(syncCompleted(_:)), name: syncCompletedNotification, object: nil)
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        setContainerSpacing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alertsManager.parentController = self
        refreshTheView()
    }
    
    //Notification when sync complete
    func syncCompleted(_ notification: Notification) {
        if let msg = notification.userInfo?["error"] as? String {
            //logout with alert
            alertsManager.presentLogoutAlert(msg)
        }
        else if let indicator = notification.userInfo?["indicator"] as? BlockingUIIndicatorView {
            DispatchQueue.main.async {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }            
            self.refreshTheView()
        }
        //else something wrong
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Navigation
    @IBAction func toHomeViewController(_ segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            print("REFRESH THE VIEW")
            if id == "backToHomeFromReader" {
                
            }
        }
    }
    
    @IBAction func signOutUser(_ sender: AnyObject) {
        self.logoutUser()
    }

    @IBAction func scanAndPerformDeviceAction(_ sender: UIButton) {
       
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "readDeviceIdSegue", sender: sender)
        }
    }
    
    @IBAction func showAllAccreditations(_ sender: AnyObject) {
        //alertsManager.presentInformationAlert("Feature not implemented", title: "All Accreditations")
        DispatchQueue.main.async { 
            self.performSegue(withIdentifier: "allAccreditationsSegue", sender: sender)
        }
    }
    @IBAction func getBackDeviceAction(_ sender: UIButton) {
        performSegue(withIdentifier: "devicesInUseSegue", sender: sender)
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueId = segue.identifier
        {
            let deviceDashboardTableController = segue.destination as? DeviceDashboardTableViewController
            switch segueId {
            case "devicesInUseSegue":
                deviceDashboardTableController!.title = "Devices in Use"
                deviceDashboardTableController!.currentScope = DeviceFilter.inUse
            case "devicesAvailableSegue":
                deviceDashboardTableController!.title = "Devices Available"
                deviceDashboardTableController!.currentScope = DeviceFilter.available
            case "devicesInRepairSegue":
                deviceDashboardTableController!.title = "Devices in Repair"
                deviceDashboardTableController!.currentScope = DeviceFilter.inRepair
            case "devicesInContractSegue":
                deviceDashboardTableController!.title = "Devices in Contract"
                deviceDashboardTableController!.currentScope = DeviceFilter.inContract
            case "allDevicesSegue":
                deviceDashboardTableController!.title = "Device Pool"
            case "accreditDevice":
                segue.destination.title = "Accredit Device"
            case "allAccreditationsSegue":
                segue.destination.title = "All Accreditations"
            case "readDeviceIdSegue":
                segue.destination.title = "Read Device"
            default:
                ()
            }
        }
        
    }
    
    //Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentAccreditations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var accCell = self.recentAccreditationsTable.dequeueReusableCell(withIdentifier: "AssignViewCell") as? AssignViewCell
        if accCell == nil {
            recentAccreditationsTable.register(UINib(nibName: "AccreditationView", bundle: nil), forCellReuseIdentifier: "AssignViewCell")
            accCell = recentAccreditationsTable.dequeueReusableCell(withIdentifier: "AssignViewCell") as? AssignViewCell
        }
        
        return accCell?.bindWithData(recentAccreditations![(indexPath as NSIndexPath).row]) ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
    //MARK: Button Tap Handlers
    
    @IBAction func inUseButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "devicesInUseSegue", sender: sender)
    }
    
    @IBAction func availableButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "devicesAvailableSegue", sender: sender)
    }
    
    @IBAction func inContractButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "devicesInContractSegue", sender: sender)
    }
    
    @IBAction func inRepairButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "devicesInRepairSegue", sender: sender)
    }
    
    //MARK: Instance Methods
    
    func refreshTheView() -> () {
        DispatchQueue.global().async {
            self.recentAccreditations = Accreditation.fetchTopAccreditations()
            self.inUseCount = Device.getDeviceCount(inType: DeviceFilter.inUse) 
            self.availableCount = Device.getDeviceCount(inType: DeviceFilter.available) 
            self.inRepairCount = Device.getDeviceCount(inType: DeviceFilter.inRepair) 
            self.inContractCount = Device.getDeviceCount(inType: DeviceFilter.inContract) 
            
            DispatchQueue.main.async {
                self.inUseButton.setTitle(String(self.inUseCount!), for: UIControlState())
                self.availableButton.setTitle(String(self.availableCount!), for: UIControlState())
                self.inRepairButton.setTitle(String(self.inRepairCount!), for: UIControlState())
                self.inContractButton.setTitle(String(self.inContractCount!), for: UIControlState())
                self.recentAccreditationsTable.reloadData()
            }
        }
    }
    
    func setContainerSpacing() -> () {
        let screenWidth = UIScreen.main.bounds.width
        switch screenWidth {
        case 375:
            containerStack.spacing = 25 * 0.67
        case 414:
            containerStack.spacing = 64 * 0.5
        case let x where x < 375:
            //3 Button view
            let extraSpace = ((x - 80) - 270)
            if extraSpace > 0 {
                containerStack.spacing = extraSpace * 0.75
            }
        case let x where x > 414:
            //4 Button view
            let extraSpace = ((x - 80) - 360)
            containerStack.spacing = extraSpace/3
        default:
            ()
        }
    }
}

extension UIViewController {
    func logoutUser() -> () {
        ServiceManager.shared.logout { (data, error, stat) in
            DispatchQueue.main.async {
                currentUser = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
