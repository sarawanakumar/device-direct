//
//  DeviceDetailsTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/26/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

protocol DeviceDataUpdaterDelegate: class {
    func textValueChanged(forCell cell: UITableViewCell, withValue value: String) -> ()
    func selectOptionChanged(forCell cell: UITableViewCell, withValue value: String) -> ()
    func scanIdButton(forCell cell: UITableViewCell)
}

class DeviceDetailsTableViewController: UITableViewController, DeviceDataUpdaterDelegate {
    
    var device: Device?
    var deviceModelType: DeviceModelType?
    var deviceController: DeviceDataController!
    var sceneScope: DeviceDetailsView? = DeviceDetailsView.newDevice
    var employeeToDisplay : [String]?
    
    weak var parentController: UIViewController?
    
    @IBOutlet weak var actionView: UIView!
    
    var selectedType: String? {
        didSet{
            deviceController.deviceType = selectedType
        }
    }
    
    var selectedModel: String? {
        didSet{
            deviceController.deviceModel = selectedModel
        }
    }
    
    var selectedOwner: String? {
        didSet{
            deviceController.deviceOwnedBy = selectedOwner
        }
    }
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(tapRecognizer)
        
        if nil == deviceController {
            deviceController = DeviceDataController()
        }
        //LOAD WITH DATA
        self.initializeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alertsManager.parentController = self
        super.viewWillAppear(animated)
    }
    
    func initializeView() -> () {
        if let d = device {
            self.sceneScope = DeviceDetailsView.existingDevice
            self.actionView.isHidden = false
            self.bindWithDevice(d)
        }
        else {
            self.sceneScope = DeviceDetailsView.newDevice
            self.actionView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func bindWithDevice(_ dev: Device) -> () {
        deviceController.deviceId = dev.id
        deviceController.deviceUdid = dev.udid
        deviceController.deviceVersion = dev.os_version
        selectedType = dev.type
        selectedModel = dev.model
        selectedOwner = dev.owned_by
    }
    
    //Data updater delegate methods
    
    func textValueChanged(forCell cell: UITableViewCell, withValue value: String) -> () {
        if let ip = tableView.indexPath(for: cell) {
            switch ((ip as NSIndexPath).section, (ip as NSIndexPath).row) {
            case (0,0):
                deviceController.deviceId = Int(value)
            case (1,0):
                deviceController.deviceUdid = value
            case (2,0):
                deviceController.deviceVersion = value
            default:
                ()
            }
        }
    }
    
    func selectOptionChanged(forCell cell: UITableViewCell, withValue value: String) -> () {
        if let ip = tableView.indexPath(for: cell) {
            switch ((ip as NSIndexPath).section, (ip as NSIndexPath).row) {
            case (3,0):
                selectedType = value
            case (3,1):
                selectedModel = value
            case (3,2):
                selectedOwner = value
            default:
                ()
            }
        }
    }
    
    func scanIdButton(forCell cell: UITableViewCell) {
        //perform segue for device scanner controller
        performSegue(withIdentifier: "scanForDeviceSegue", sender: cell)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if sceneScope == DeviceDetailsView.newDevice {
            return 4
        }
        else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 3
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let ip = ((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row)
        if sceneScope == DeviceDetailsView.newDevice {
            switch ip {
            case (0,0):
                //ID
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceTextnCodeCell", for: indexPath) as! DeviceTextnCodeTableViewCell
                cell.deviceTextField.placeholder = "Device Id"
                if let id = deviceController.deviceId {
                    cell.deviceTextField.text = String(id)
                }
                cell.delegate = self
                return cell
            case (1,0):
                //UDID
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceTextCell", for: indexPath) as! DeviceTextTableViewCell
                cell.delegate = self
                cell.deviceTextField.placeholder = "Device UDID"
                return cell
            case (2,0):
                //VERSION
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceTextCell", for: indexPath) as! DeviceTextTableViewCell
                cell.delegate = self
                cell.deviceTextField.placeholder = "Device Version"
                return cell
            case (3,0):
                //TYPE
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceOptionCell", for: indexPath) as! DeviceOptionTableViewCell
                cell.titleLabel.text = "Device Type"
                cell.delegate = self
                return cell
            case (3,1):
                //MODEL
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceOptionCell", for: indexPath) as! DeviceOptionTableViewCell
                cell.delegate = self
                cell.titleLabel.text = "Device Model"
                return cell
            case (3,2):
                //OWNED BY
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceOptionCell", for: indexPath) as! DeviceOptionTableViewCell
                cell.delegate = self
                cell.titleLabel.text = "Owned By"
                return cell
            default:
                ()
            }
        }
        else {
            switch ip {
            case (0,0):
                //ID
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceTextnCodeCell", for: indexPath) as! DeviceTextnCodeTableViewCell
                cell.deviceTextField.text = String(deviceController.deviceId!)
                cell.delegate = self
                cell.scanButton.isHidden = true
                cell.editable = false
                return cell
            case (1,0):
                //UDID
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceTextCell", for: indexPath) as! DeviceTextTableViewCell
                cell.delegate = self
                cell.editable = false
                cell.deviceTextField.text = deviceController.deviceUdid
                return cell
            case (2,0):
                //VERSION
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceTextCell", for: indexPath) as! DeviceTextTableViewCell
                cell.delegate = self
                cell.deviceTextField.text = deviceController.deviceVersion
                return cell
            case (3,0):
                //TYPE
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceOptionCell", for: indexPath) as! DeviceOptionTableViewCell
                cell.titleLabel.text = "Device Type"
                cell.valueLabel.text = selectedType
                cell.selectionStyle = .none
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.delegate = self
                return cell
            case (3,1):
                //MODEL
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceOptionCell", for: indexPath) as! DeviceOptionTableViewCell
                cell.delegate = self
                cell.titleLabel.text = "Device Model"
                cell.valueLabel.text = selectedModel
                cell.selectionStyle = .none
                cell.accessoryType = UITableViewCellAccessoryType.none
                return cell
            case (3,2):
                //OWNED BY
                let cell = tableView.dequeueReusableCell(withIdentifier: "deviceOptionCell", for: indexPath) as! DeviceOptionTableViewCell
                cell.delegate = self
                cell.titleLabel.text = "Owned By"
                cell.valueLabel.text = selectedOwner
                return cell
            default:
                ()
            }
        }

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Device ID"
        case 1:
            return "Device UDID"
        case 2:
            return "Device Version"
        case 3:
            return "Other Details"
        default:
            return "Device Actions"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 3 && (indexPath as NSIndexPath).row == 1 {
            if deviceController.deviceType == nil
            {
                alertsManager.presentInformationAlert("Select Device type", title: "Alert")
                
            }
        }
    }
        
        
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var performSegue = true
        if sceneScope == DeviceDetailsView.existingDevice {
            if let cell = sender as? UITableViewCell {
                let ip = tableView.indexPath(for: cell)
                switch ((ip! as NSIndexPath).section, (ip! as NSIndexPath).row) {
                case (3,0), (3,1):
                    return false
                case (3,2):
                    if let employees = Employee.getAllEmployeeNames() {
                        employeeToDisplay = employees
                        return true
                    }
                    else {
                        return false
                    }                    
                default:
                    ()
                }
            }
        }
        else {
            if let cell = sender as? UITableViewCell {
                let ip = tableView.indexPath(for: cell)
                switch ((ip! as NSIndexPath).section, (ip! as NSIndexPath).row) {
                case (3,0):
                    if deviceController.deviceModel != nil {
                        alertsManager.presentInformationAlert("Device Type already selected", title: "Alert")
                        tableView.deselectRow(at: ip!, animated: true)
                        return false
                    }
                    return true
                case (3,1):
                    if deviceController.deviceType == nil {
                        alertsManager.presentInformationAlert("Select Device type", title: "Alert")
                        tableView.deselectRow(at: ip!, animated: true)
                        return false
                    }
                    return true
                case (3,2):
                     employeeToDisplay = Employee.getAllEmployeeNames()
                     if employeeToDisplay != nil {
                        return true
                    }
                     else {
                        alertsManager.presentInformationAlert("No Employee details", title: "Error Alert")
                        return false
                    }
                default:
                    return true
                }
            }
            /*if identifier == "selectDeviceModel" {
                performSegue = selectedType != nil
            }
            else if identifier == "saveDeviceAndReturnToPool" || identifier == "saveDeviceAndReturnToHome" {
                performSegue = validateDetails() && isDeviceIdUnique(deviceId!)
            }*/
        }
        return performSegue
    }
    
    // MARK: - Navigation
    
    @IBAction func saveOptionSegue(_ segue: UIStoryboardSegue) {
        //To land into Device details page
        //Expected Segues:
        //saveOption->OptionsTableViewController
    }
    

    // Before moving out of the current controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier  {
            if id == "showDeviceOptionsSegue"  {
                let optionController = segue.destination as! OptionsTableViewController
                let cell = sender as! DeviceOptionTableViewCell
                let ip = tableView.indexPath(for: cell)
                
                optionController.delegate = cell
                switch ((ip! as NSIndexPath).section, (ip! as NSIndexPath).row) {
                case (3,0):
                    optionController.options = deviceTypes
                    optionController.optionType = OptionType.deviceTypes
                    optionController.selectedOption = selectedType
                case (3,1):
                    if let type = selectedType {
                       // optionController.options = deviceModels[type]
                        optionController.selectedType = type
                        optionController.options = DeviceModelType.getDeviceModel(type)
                        optionController.optionType = OptionType.deviceModels(type)
                        optionController.selectedOption = selectedModel
                    }
                case (3,2):
                        optionController.options = employeeToDisplay
                        optionController.optionType = OptionType.manager
                        optionController.selectedOption = selectedOwner
                default:
                    ()
                }
            }
            else if id == "performActionAndGotoDashBoard" {
                let dashboardController = segue.destination as! DeviceDashboardTableViewController
                dashboardController.reloadRequired = true
            }
            else if id == "scanForDeviceSegue" {
                let readerController = segue.destination as! DeviceReaderViewController
                readerController.isNewDeviceMode = true
                readerController.sender = sender as AnyObject?
            }
            else if id == "accreditTheDeviceSegue"
            {
                let accreditationController = segue.destination as! AccreditationViewController
                accreditationController.device = self.device
            }
            else if id == "contractDeviceSegue" {
                let contractDeviceController = segue.destination as! ContractDeviceTableViewController
                contractDeviceController.title = "Contract Device"
                contractDeviceController.device = self.device
            }
        }
    }
    
    @IBAction func toDeviceDetailsTableController(_ segue: UIStoryboardSegue){
        //To land into Device details page
        //Expected Segues: deviceIdScannedSegue->DeviceReaderViewController
        if let id = segue.identifier {
            if id == "deviceIdScannedSegue" {
                let sender = (segue.source as! DeviceReaderViewController).sender
                updateTheSender(sender)
            }
        }
    }
    
    func updateTheSender(_ sender: AnyObject?) -> () {
        if let cell = sender as? DeviceTextnCodeTableViewCell, let id = deviceController.deviceId {
            cell.deviceTextField.text = String(id)
        }
    }
    
    //MARK: Button Taps
    @IBAction func saveDeviceButtonTapped(_ sender: AnyObject) {
        var segueId = "performActionAndGotoDashBoard"
        
        if let vc = parentController , vc is DeviceReaderViewController {
            segueId = "saveDeviceAndReturnToHome"
        }
        
        
        if sceneScope == DeviceDetailsView.newDevice {
            if validateDetails() {
                self.waitForBlock { (activityIndicator) in
                    deviceController.isDeviceIdUnique(deviceController.deviceId!) { (unique) in
                        if unique {
                            //create the device
                            self.deviceController.createAndSaveNewDevice { (success, message) in
                                self.dispatchInMain {
                                    activityIndicator.stopAnimating()
                                    if success {
                                        self.performSegue(withIdentifier: segueId, sender: sender)
                                    }
                                    else {
                                        self.alertWithErrorMessage(message!)
                                    }
                                }
                            }
                        }
                        else {
                            self.dispatchInMain {
                                activityIndicator.stopAnimating()
                                alertsManager.presentInformationAlert("Device ID already exists", title: "Device Exists")
                            }
                        }
                    }
                }
            }
        }
        else {
            if isOsVersionValid() {
                self.waitForBlock { (activityIndicator) in
                    deviceController.updateDeviceDetails(device!) { (success, errorMessage) in
                        self.dispatchInMain {
                            activityIndicator.stopAnimating()
                            if success {
                                self.performSegue(withIdentifier: segueId, sender: sender)
                            }
                            else {
                                self.alertWithErrorMessage(errorMessage!)
                            }

                        }
                    }
                }
            }
        }
    }
    
    @IBAction func assignDeviceButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "accreditTheDeviceSegue", sender: sender)
    }
    
    @IBAction func contractDeviceButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "contractDeviceSegue", sender: sender)
    }
    
    @IBAction func removeDeviceButtonTapped(_ sender: UIButton) {
        let msg = "Do you want permanently remove this device from pool?"
        let title = "Remove Device"
        alertsManager.presentActionAlert(msg, title: title, okAction: { 
                self.removeDeviceFromPool(sender)
            }, cancelAction: nil)
    }
    
    @IBAction func sendForRepairButtonTapped(_ sender: UIButton) {
        let msg = "Do you want send this device for repair?"
        let title = "Send for Repair"
        alertsManager.presentActionAlert(msg, title: title, okAction: {
            self.updateDeviceStatus(sender,status: DeviceFilter.inRepair)
            }, cancelAction: nil)
    }
    
    
    //MARK: API & COREDATA HANDLERS
    
    func updateDeviceStatus(_ sender: UIButton,status: DeviceFilter) -> () {
        self.waitForBlock { (activity) in
            deviceController.updateDeviceStatus( bodyDict: ["device_status": Int(status.rawValue) as AnyObject ] ) { (success, errorMessage) in
                self.dispatchInMain {
                    activity.stopAnimating()
                    if success {
                        self.device?.changeDeviceStatus(status) { msg in
                            if let m = msg {
                                alertsManager.presentLogoutAlert(m, title: "Error on Save.")
                            }
                            else {
                                 self.performSegue(withIdentifier: "performActionAndGotoDashBoard", sender: sender)
                            }
                        }
                    }
                    else {
                        alertsManager.presentInformationAlert(errorMessage!, title: "Server Error")
                    }
                }
            }
        }
    }
    
    func removeDeviceFromPool(_ sender: UIButton) -> Void {
        self.waitForBlock { (activity) in
            deviceController.removeDevice { (success, errorMessage) in
                self.dispatchInMain {
                    activity.stopAnimating()
                    if success {
                        self.performSegue(withIdentifier: "performActionAndGotoDashBoard", sender: sender)
                    }
                    else {
                        self.alertWithErrorMessage(errorMessage!)
                    }
                }
                
            }
        }
        
    }
    
    
    //MARK: Instance helper method
    
    func validateDetails() -> Bool {
        if String(describing: deviceController.deviceId) == ""
        {
            alertsManager.presentInformationAlert("Enter Device Id", title: "Alert")
            return false
        }
        if String(describing: deviceController.deviceUdid) == ""
        {
            alertsManager.presentInformationAlert("Enter Device Udid", title: "Alert")
            return false
        }
        if selectedType == nil || selectedModel == nil
        {
            alertsManager.presentInformationAlert("Select Device type and Model", title: "Alert")
            return false
        }
        return isOsVersionValid()
    }
    
    func isOsVersionValid() -> Bool {
        if deviceController.deviceVersion == ""
        {
            alertsManager.presentInformationAlert("Enter OS version", title: "Alert")
            return false
        }
        return true
    }
}

extension UIViewController {
    func alertWithErrorMessage(_ message: String) {
        OperationQueue.main.addOperation({
        //    let window = UIApplication.shared.window
            UIApplication.shared.windows[0].isUserInteractionEnabled = true

            alertsManager.presentInformationAlert(message, title: "Server Error")
        })
    }
}
