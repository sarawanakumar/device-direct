//
//  DeviceDetailsViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/31/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class DeviceDetailsViewController: UITableViewController, UITextFieldDelegate {
    
    var device: Device?
    var sceneScope: DeviceDetailsView?
    
    @IBOutlet weak var deviceIdCell: UITableViewCell!
    @IBOutlet weak var deviceTypeCell: UITableViewCell!
    @IBOutlet weak var deviceModelCell: UITableViewCell!
    @IBOutlet weak var deviceVersionCell: UITableViewCell!
    @IBOutlet weak var deviceIdTextField: UITextField!
    @IBOutlet weak var deviceVersionTextField: UITextField!
    @IBOutlet weak var bottomDashboardView: UIView!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scanButton: UIButton!
    
    weak var parentController: UIViewController?
    var selectedDeviceType: String?
    var selectedDeviceModel: String?
    var deviceIdFromScanner: Int?
    var deviceId: Int? {
        get {
            //return Int(deviceIdTextField.text!) ?? Int((deviceIdCell.textLabel?.text)!)
            return Int(deviceIdTextField.text!)
        }
        set {
            if let val = newValue {
                deviceIdTextField.text = String(val)
                //deviceIdCell.textLabel?.text = String(val)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(tapRecognizer)
        
        //Set Current scope for screen
        if let _ = device {
            self.sceneScope = DeviceDetailsView.existingDevice
            tableViewInitSettings(withDevice: true)
        }
        else {
            self.sceneScope = DeviceDetailsView.newDevice
            tableViewInitSettings()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //if let dev = device {
        alertsManager.parentController = self
        if sceneScope == .existingDevice {
            //deviceIdCell.textLabel?.text = String((device?.id)!)
            deviceIdTextField.text = String((device?.id)!)
            deviceTypeCell.textLabel?.text = device?.type
            deviceModelCell.textLabel?.text = device?.model
            //deviceVersionCell.textLabel?.text = device?.os_version
            deviceVersionTextField.text = device?.os_version
            scanButton.isHidden = true
        }
        else {
            scanButton.layer.cornerRadius = 5.0
            scanButton.layer.masksToBounds = true
            tableViewInitSettings()
        }
    }
    
    @IBAction func scanButtonTapped(_ sender: AnyObject) {
        OperationQueue.main.addOperation { 
            self.performSegue(withIdentifier: "scanForDeviceSegue", sender: sender)
        }
    }
    
    
    func tableViewInitSettings(withDevice haveDevice: Bool = false) -> () {
        if haveDevice {
            //deviceIdTextField.hidden = true
            //deviceVersionTextField.hidden = true
            deviceTypeCell.accessoryType = .none
            deviceModelCell.accessoryType = .none
        }
        else {
            if let id = deviceIdFromScanner {
                deviceId = id
            }
            deviceTypeCell.detailTextLabel?.text = selectedDeviceType ?? "Select Device Type"
            deviceModelCell.detailTextLabel?.text = selectedDeviceModel ?? "Select Device Model"
            bottomDashboardView.isHidden = true
        }
    }

    @IBAction func viewTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            if self.deviceTypeCell.detailTextLabel?.text == "Select Device Type"             {
                alertsManager.presentInformationAlert("Select Device type", title: "Alert")
                
            }
        }
        /*if sceneScope == DeviceDetailsView.ExistingDevice {
            if indexPath.section == 3 && indexPath.row == 0 {
                deviceVersionTextField.text = deviceVersionCell.textLabel?.text
                deviceVersionCell.textLabel?.hidden = true
                deviceVersionTextField.hidden = false
                deviceVersionTextField.becomeFirstResponder()
            }
        }*/
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func saveOptionSegue(_ segue: UIStoryboardSegue) {
        if segue.identifier == "saveOption" {
            let optionsController = segue.source as? OptionsTableViewController
            let option = (optionsController?.optionType)!
            switch option {
            case OptionType.deviceTypes:
                selectedDeviceType = (optionsController?.selectedOption)!
            case OptionType.deviceModels(let type):
                if type == selectedDeviceType {
                    selectedDeviceModel = (optionsController?.selectedOption)!
                }
            default:
                ()
            }
        }
        else if segue.identifier == "deviceIdScannedSegue" {
            print("Device id scan was successful")
        }
    }
    
    @IBAction func saveDeviceButtonTapped(_ sender: AnyObject) {
        var segueId = "saveDeviceAndReturnToPool"
        
        if let vc = parentController , vc is DeviceReaderViewController {
            segueId = "saveDeviceAndReturnToHome"
        }
        if sceneScope == DeviceDetailsView.newDevice {
            if validateDetails() && isDeviceIdUnique(deviceId!) {
                OperationQueue.main.addOperation({ 
                    self.performSegue(withIdentifier: segueId, sender: self)
                })
            }
        }
        else {
            if isOsVersionValid() {
                OperationQueue.main.addOperation({
                    self.performSegue(withIdentifier: segueId, sender: self)
                })
            }
        }
    }
    
    func updateDeviceStatus(_ sender: AnyObject?) -> () {
        let device = Device.getDeviceById(self.deviceId!)
        device?.changeDeviceStatus(.inRepair) { err in
            if let e = err {
                alertsManager.presentLogoutAlert(e)
            }
            else {
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "sendForRepairAndReturnToPool", sender: sender)
                })
            }
        }
    }
    
    func removeDeviceFromPool(_ sender: AnyObject?) -> Void {
        Device.removeDevice(withId: self.deviceId!) { (data) in
            if data {
                dataController.saveToPersistentStore(completion: { (msg) in
                    if let m = msg {
                        alertsManager.presentLogoutAlert(m)
                    }
                    else {
                        DispatchQueue.main.async(execute: {
                            self.performSegue(withIdentifier: "removeDeviceAndReturnToPool", sender: sender)
                        })
                    }
                })
            }
            else {
                alertsManager.presentInformationAlert("No device found.", title: "Device not exists")
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var performSegue = true
        if sceneScope == DeviceDetailsView.existingDevice {
            performSegue = false
            switch identifier {
            case "removeDeviceAndReturnToPool":
                if deviceIdExists(deviceId!) {
                    let message = "Device will be removed from Device Pool"
                    let title = "Remove Device"
                    alertsManager.presentActionAlert(message, title: title, okAction: {
                        self.removeDeviceFromPool(sender as AnyObject?)
                        }, cancelAction: nil)
                }
            case "saveDeviceAndReturnToPool":
                performSegue = isOsVersionValid()
            case "accreditDevice":
                performSegue = true
            case "sendForRepairAndReturnToPool":
                if deviceIdExists(deviceId!) {
                    let message = "Device will be tagged under Repaired Devices"
                    let title = "Send for Repair"
                    alertsManager.presentActionAlert(message, title: title, okAction: {
                        self.updateDeviceStatus(sender as AnyObject?)
                    }, cancelAction: nil)
                }
            default:
                ()
            }
        }
        else {
            if identifier == "selectDeviceModel" {
                performSegue = selectedDeviceType != nil
            }
            else if identifier == "saveDeviceAndReturnToPool" || identifier == "saveDeviceAndReturnToHome" {
                performSegue = validateDetails() && isDeviceIdUnique(deviceId!)
            }
        }        
        return performSegue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "selectDeviceType":
                let optionsContoller = segue.destination as? OptionsTableViewController
                optionsContoller?.title = "Device Types"
                optionsContoller?.optionType = OptionType.deviceTypes
                optionsContoller?.options = deviceTypes
                optionsContoller?.selectedOption = selectedDeviceType
            case "selectDeviceModel":
                let optionsContoller = segue.destination as? OptionsTableViewController
                optionsContoller?.title = "Device Models"
                optionsContoller?.optionType = OptionType.deviceModels(selectedDeviceType!)
                optionsContoller?.options = deviceModels[selectedDeviceType!]
                optionsContoller?.selectedOption = selectedDeviceModel
            case "saveDeviceAndReturnToPool", "saveDeviceAndReturnToHome":
                if sceneScope == DeviceDetailsView.existingDevice {
                    let tmpDev = Device.getDeviceById(self.deviceId!)
                    tmpDev?.os_version = self.deviceVersionTextField.text
                    dataController.saveToPersistentStore { msg in
                        if let m = msg {
                            alertsManager.presentLogoutAlert(m)
                        }
                    }
                }
                else {
                    createAndSaveNewDevice()
                }
                let dashboardController = segue.destination as? DeviceDashboardTableViewController
                dashboardController?.reloadRequired = true
                dashboardController?.deviceIdToFocus = self.deviceId
            case "removeDeviceAndReturnToPool", "sendForRepairAndReturnToPool":
                let dashboardController = segue.destination as? DeviceDashboardTableViewController
                dashboardController?.reloadRequired = true
            case "accreditDevice":
                let accreditationController = segue.destination as? AccreditationViewController
                accreditationController?.device = self.device
                accreditationController?.title = "Accredit Device"
            case "scanForDeviceSegue":
                let readerController = segue.destination as! DeviceReaderViewController
                readerController.isNewDeviceMode = true
            default:
                ()
            }
        }
    }
    
    func createAndSaveNewDevice() -> () {
        Device.createDevice { newDevice in
            newDevice.device_status = DeviceFilter.available.rawValue
            newDevice.id = self.deviceId!
            newDevice.type = self.selectedDeviceType
            newDevice.model = self.selectedDeviceModel
            newDevice.os_version = self.deviceVersionTextField.text
            dataController.saveToPersistentStore { err in
                if let e = err {
                    alertsManager.presentLogoutAlert(e)
                }
                else {
                    
                }
            }
        }
    }
    
    func saveDeviceDetails() {
        if sceneScope == DeviceDetailsView.newDevice {
            if validateDetails() {
                if isDeviceIdUnique(self.deviceId!) {
                    
                }
                else {
                    print("non-unique device id")
                }
            }
            else {
                print("invalid details")
            }
        }
    }
    
    func validateDetails() -> Bool {
        if deviceIdTextField.text == ""
        {
            alertsManager.presentInformationAlert("Enter Device Id", title: "Alert")
            return false
        }
        if deviceTypeCell.detailTextLabel?.text == "Select Device Type" || deviceModelCell.detailTextLabel?.text == "Select Device Model"
        {
            alertsManager.presentInformationAlert("Select Device type and Model", title: "Alert")
            return false
        }
        return isOsVersionValid()
    }
    
    func isDeviceIdUnique(_ devId: Int) -> Bool {
        if Device.getDeviceById(devId) != nil
        {
            alertsManager.presentInformationAlert("Non-unique device id", title: "Alert")
            return false
        }
        
        return true
    }
    
    func deviceIdExists(_ deviceId: Int) -> Bool {
        return true
    }
    
    func isOsVersionValid() -> Bool {
        if deviceVersionTextField.text == ""
        {
            alertsManager.presentInformationAlert("Enter OS version", title: "Alert")
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == deviceVersionTextField {
            return true
        }
        else {
            return sceneScope == DeviceDetailsView.newDevice
        }
    }
}
