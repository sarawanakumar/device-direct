//
//  DeviceDashboardTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/25/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class DeviceDashboardTableViewController: UITableViewController, UISearchBarDelegate {
    var currentScope: DeviceFilter!
    var devicesToPresent: [Device]!
    var allDevicesForScope: [Device]!
    var rowEditTitle: String?
    var rowEditColor: UIColor?
    var reloadRequired = false
    var deviceIdToFocus: Int?
    
    let deviceController = DeviceDataController()
    let contractController = ContractDataController()
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var padCount: UILabel!
    @IBOutlet weak var watchCount: UILabel!
    @IBOutlet weak var phoneCount: UILabel!
    
    @IBOutlet weak var countsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(tapRecognizer)
        //loading the data
        allDevicesForScope = Device.getDevices(filteredBy: currentScope)
        
        if currentScope == nil {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableViewData(forText: searchBar.text!)
        initDataForScope(currentScope)
        alertsManager.parentController = self
    }
    
    func updateDeviceCountView() {
        let totalPads = devicesToPresent.filter({$0.type == "Pad"}).count 
        let totalPhones = devicesToPresent.filter({$0.type == "Phone"}).count 
        let totalWatches = devicesToPresent.filter({$0.type == "Watch"}).count 
        OperationQueue.main.addOperation { 
            self.phoneCount.text = String(totalPhones)
            self.padCount.text = String(totalPads)
            self.watchCount.text = String(totalWatches)
        }        
    }
    
    func initDataForScope(_ scope: DeviceFilter?) {
        if let validScope = scope {
            switch validScope {
            case .available:
                rowEditTitle = "  Accredit  "
                rowEditColor = UIColor.purple
            case .inUse:
                rowEditTitle = "   Return   "
                rowEditColor = UIColor(red: 33.0/255.0, green: 162.0/255.0, blue: 224.0/255, alpha: 1.0)
            case .inContract:
                rowEditTitle = "   Return   "
                rowEditColor = UIColor(red: 33.0/255.0, green: 162.0/255.0, blue: 224.0/255, alpha: 1.0)
            case .inRepair:
                rowEditTitle = "Add to Pool"
                rowEditColor = UIColor.gray
            }
        }
    }

    @IBAction func viewTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("SEARCH THE DATA")
        updateTableViewData(forText: searchText.lowercased())
    }
    
    func updateTableViewData(forText searchText:String, andReload reload: Bool = true) {
        if searchText.lengthOfBytes(using: String.Encoding.utf32) > 0 {
            devicesToPresent = searchInDeviceData(allDevicesForScope, forText: searchText)
        }
        else {
            devicesToPresent = allDevicesForScope
        }
        if devicesToPresent.count < 1 {
            if let v = getNoDataView() {
                tableView.backgroundView = v
                tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            }
            print("table is empty")
        }
        else {
            tableView.backgroundView = nil
            tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
        }
        if reload {
            self.tableView.reloadData()
        }
        updateDeviceCountView()
    }
    
    func searchInDeviceData(_ devices: [Device], forText text: String) -> [Device] {
        var result = [Device]()
        if text.isEmpty {
            return devices
        }
        for device in devices {
            if device.matchesWith(text) {
                result.append(device)
            }
        }
        return result
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var totalRows = 0
        if let dev = devicesToPresent {
            totalRows = dev.count
        }
        return totalRows
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var devStatus: DeviceFilter?
        if nil == currentScope {
            if let currDevCell = tableView.cellForRow(at: indexPath) as? DeviceTableViewCell {
                initDataForScope(currDevCell.cellType)
                devStatus = DeviceFilter(rawValue: devicesToPresent[(indexPath as NSIndexPath).row].device_status)!
            }            
        }
        let tableViewRowAction = UITableViewRowAction(style: .normal, title: rowEditTitle) { (rowAction, indexPath) in
            self.performCellEditAction((self.currentScope ?? devStatus), atIndexPath: indexPath)
        }
        tableViewRowAction.backgroundColor = rowEditColor
        return [tableViewRowAction]
    }
    
    func reloadRowAtIndexPath(_ indexPath: IndexPath) {
        OperationQueue.main.addOperation { 
            //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    func returnDevice(_ indexPath: IndexPath) {
        let device = devicesToPresent[(indexPath as NSIndexPath).row]
        self.waitForBlock { (activityBar) in
            AccreditationDataController.removeAccreditation(havingId: device.accreditation_id) { (success, message) in
                self.dispatchInMain {
                    activityBar.stopAnimating()
                    if success {
                        self.allDevicesForScope = Device.getDevices(filteredBy: self.currentScope)
                        self.updateTableViewData(forText: self.searchBar.text!, andReload: false)
                        if let _ = self.currentScope {
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        else {
                            UIView.animate(withDuration: 0.5, animations: {
                                self.tableView.setEditing(false, animated: true)
                            })
                            UIView.animate(withDuration: 0.5, animations: {
                                self.tableView.reloadRows(at: [indexPath], with: .fade)
                            })                            
                        }
                        
                        print("Device returned")
                    }
                    else
                    {
                        self.alertWithErrorMessage(message!)
                    }
                }
            }
        }
        
    }
    
    func returnContractDevice(_ indexPath: IndexPath)
    {
        let device = devicesToPresent[(indexPath as NSIndexPath).row]
     //   device.device_status = DeviceFilter.available.rawValue
        let contract = Contract.getContractById(device.contract_id)
    //    device.contract_id = -1
        
        self.waitForBlock { (activityBar) in
            contractController.removeContract(device, contract) { (success, message) in
                self.dispatchInMain {
                    activityBar.stopAnimating()
                    if success {
                        self.allDevicesForScope = Device.getDevices(filteredBy: self.currentScope)
                        self.updateTableViewData(forText: self.searchBar.text!, andReload: false)
                        if let _ = self.currentScope {
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        else {
                            UIView.animate(withDuration: 0.5, animations: {
                                self.tableView.setEditing(false, animated: true)
                            })
                            UIView.animate(withDuration: 0.5, animations: {
                                self.tableView.reloadRows(at: [indexPath], with: .fade)
                            })
                        }
                        
                    }
                    else {
                        self.alertWithErrorMessage(message!)
                    }
                }
            }
        }
    }
    
    func addRepairedDeviceToPool(_ indexPath: IndexPath) {
        let device = devicesToPresent[(indexPath as NSIndexPath).row]
        deviceController.deviceId = device.id
        self.waitForBlock { (activityIndicator) in
            deviceController.updateDeviceStatus(bodyDict: ["device_status": Int(DeviceFilter.available.rawValue) as AnyObject]) { success , errMsg in
                self.dispatchInMain {
                    activityIndicator.stopAnimating()
                    if success {
                        device.changeDeviceStatus(DeviceFilter.available) { msg in
                            if let m = msg {
                                alertsManager.presentLogoutAlert(m)
                            }
                            else {
                                self.allDevicesForScope = Device.getDevices(filteredBy: self.currentScope)
                                self.updateTableViewData(forText: self.searchBar.text!, andReload: false)
                                if let _ = self.currentScope {
                                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                                }
                                else {
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                    else {
                        alertsManager.presentInformationAlert("No Details", title: "Error Occurred")
                    }
                }
            }
        }
        print("Device Added back to pool")
    }
    
    func performCellEditAction(_ actionType: DeviceFilter?, atIndexPath indexPath: IndexPath) -> () {
        if let action = actionType {
            switch action {
            case .available:
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "assignDevice", sender: indexPath)
                })
            case .inUse:
                let message = "Device will be added back to pool"
                let title = "Return Device"
                alertsManager.presentActionAlert(message, title: title, okAction: { self.returnDevice(indexPath) } , cancelAction: { self.reloadRowAtIndexPath(indexPath) })
            case .inContract:
                let message = "Device will be added back to pool"
                let title = "Return Device"
                alertsManager.presentActionAlert(message, title: title, okAction: { self.returnContractDevice(indexPath) } , cancelAction: { self.reloadRowAtIndexPath(indexPath) })
            case .inRepair:
                let message = "Device will be added back to pool"
                let title = "Repaired Device"
                alertsManager.presentActionAlert(message, title: title, okAction: { self.addRepairedDeviceToPool(indexPath) } , cancelAction: { self.reloadRowAtIndexPath(indexPath) })
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let devCell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as? DeviceTableViewCell {
            return devCell.bindWithData(devicesToPresent[(indexPath as NSIndexPath).row], inAllDevices: currentScope == nil)
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if nil == currentScope {
            if let currDevCell = tableView.cellForRow(at: indexPath) as? DeviceTableViewCell {
                if currDevCell.cellType == .available {
                    //Navigate to edit device page
                    guard let deviceDetailsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "deviceDetailsDynamic") as? DeviceDetailsTableViewController else { return }
                    deviceDetailsController.title = "Device Details"
                    deviceDetailsController.device = devicesToPresent[(indexPath as NSIndexPath).row]
                    self.navigationController?.pushViewController(deviceDetailsController, animated: true)
                }
                else if currDevCell.cellType == .inContract {
                    //Navigate to contract page
                    guard let deviceContractController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contractDeviceController") as? ContractDeviceTableViewController else { return }
                    deviceContractController.title = "Contract Details"
                    deviceContractController.device = devicesToPresent[(indexPath as NSIndexPath).row]
                    self.navigationController?.pushViewController(deviceContractController, animated: true)
                }
            }
        //}
    }
    
    
    
    @IBAction func fromDeviceDetails(_ segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            switch id {
            case "saveDeviceAndReturnToPool", "performActionAndGotoDashBoard":
                if reloadRequired {
                    //self.devicesToPresent = Device.getDevices(filteredBy: nil)
                    allDevicesForScope = Device.getDevices(filteredBy: self.currentScope)
                    updateTableViewData(forText: searchBar.text!, andReload: reloadRequired)
                    self.reloadRequired = false
                    if let focusId = self.deviceIdToFocus {
                        let ip = self.getCellIndexPathFromDeviceId(focusId)
                        
                        let popTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: popTime) {
                            //self.tableView.selectRowAtIndexPath(ip, animated: false, scrollPosition: .None)
                            //self.tableView.scrollToRowAtIndexPath(ip!, atScrollPosition: .Bottom, animated: true)
                            
                            
                        }
                    }
                }
            default:
                if reloadRequired {
                    allDevicesForScope = Device.getDevices(filteredBy: self.currentScope)
                    updateTableViewData(forText: searchBar.text!, andReload: reloadRequired)
                    self.reloadRequired = false
                }
            }
        }
    }
    
    func doAnimation(forCellWithIndexPath indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func getCellIndexPathFromDeviceId(_ deviceId: Int) -> IndexPath? {
        var indexPath: IndexPath?
        
        for device in devicesToPresent {
            if device.id == deviceId {
                indexPath = IndexPath(row: devicesToPresent.index(of: device)!, section: 0)
                break
            }
        }
        
        return indexPath
    }
    
    func getNoDataView() -> UIView? {
        return UINib(nibName: "NoDataView", bundle: nil).instantiate(withOwner: nil, options: nil)[0]
            as? UIView
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id == "addDevice" {
                let devDetailsController = segue.destination as? DeviceDetailsViewController
                devDetailsController?.sceneScope = .some(DeviceDetailsView.newDevice)
                segue.destination.title = "Add Device"
            }
            else if id == "assignDevice" {
                if let accrController = segue.destination as? AccreditationViewController,
                    let ip = sender as? IndexPath {
                    accrController.device = devicesToPresent[(ip as NSIndexPath).row]
                }
            }
        }
    }
 
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if let focusId = self.deviceIdToFocus {
            print("scroll view ended")
            let ip = self.getCellIndexPathFromDeviceId(focusId)
            /*UIView.animateWithDuration(0.1, delay: 0.3, options: .CurveLinear, animations: {
                    self.tableView.selectRowAtIndexPath(ip!, animated: true, scrollPosition: .None)
                }, completion: { (completed) in
                    UIView.animateWithDuration(0.1, animations: {
                        self.tableView.deselectRowAtIndexPath(ip!, animated: true)
                    })
            })*/
            UIView.animate(withDuration: 0.4, delay: 0.5, options: .curveLinear, animations: {
                //self.tableView.deselectRowAtIndexPath(ip!, animated: true)
                self.tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
                }, completion: {(completed) in ()})
            
        }
    }
}

extension UIViewController {
    func dispatchInMain(_ block: @escaping ()->()) -> () {
        DispatchQueue.main.async {
            block()
        }
    }
}
