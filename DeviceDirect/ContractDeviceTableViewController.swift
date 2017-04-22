//
//  ContractDeviceTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 10/2/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

protocol DataUpdaterDelegate: class {
    func updateEmployeeName(_ name: String, forCell cell: UITableViewCell)
    func updateEmployeeId(_ id: String, forCell cell: UITableViewCell)
    func updateTextValue(_ value: String, forCell cell: UITableViewCell)
}

class ContractDeviceTableViewController: UITableViewController, DataUpdaterDelegate {
    
    var device: Device?
    var contract: Contract?
    var deviceController : DeviceDataController?
    var contractController : ContractDataController?
    var newContract = true
    
    var contractTeam: String?
    var employeeName: String?
    var employeeId: String?
    @IBOutlet weak var actionButton: UIButton!
    
    let cellType = ["Device":"deviceDetailsCell","TextField":"textFieldCell","Employee":"employeeCell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertsManager.parentController = self
        if nil == deviceController {
            deviceController = DeviceDataController()
        }
        if nil == contractController {
            contractController = ContractDataController()
        }
        loadDeviceContractAsRequired()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if newContract {
            switch section {
            case 0, 2:
                return 1
            default:
                return 2
            }
        }
        else {
            switch section {
            case 0, 2:
                return 1
            default:
                return 3
            }
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if newContract {
            cell = getNewContractCellForIndexPath(((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row))
        }
        else {
            cell = getExistingContractCellForIndexPath(((indexPath as NSIndexPath).section,(indexPath as NSIndexPath).row))
        }

        return cell
    }
    

    
    func getNewContractCellForIndexPath(_ ip: (Int, Int)) -> UITableViewCell {
        var currCell: UITableViewCell!
        switch ip {
        case (0,0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["Device"]!) as? ContractDeviceTableViewCell {
                cell.deviceModelLabel.text = device?.model
                cell.deviceIdLabel.text = "(\(device!.id))"
                cell.versionLabel.text = device?.os_version
                currCell = cell
            }
        case (1,0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["TextField"]!) as? ContractTextFieldTableViewCell {
                cell.textField.placeholder = "Project Name"
                cell.delegate = self
                cell.editable = true
                currCell = cell
            }
        case (1,1):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["Employee"]!) as? ContractEmployeeTableViewCell {
                cell.employeeNameField.placeholder = "Employee Name"
                cell.employeeIdField.placeholder = "Employee Id"
                cell.editable = true
                cell.delegate = self
                currCell = cell
            }
        case (2,0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["TextField"]!) as? ContractTextFieldTableViewCell {
                cell.textField.text = currentUser?.userName ?? "No Auth"
                currCell = cell
            }
        default:
            ()
        }
        return currCell
    }
    
    func getExistingContractCellForIndexPath(_ ip: (Int, Int)) -> UITableViewCell {
        var currCell: UITableViewCell!
        switch ip {
        case (0,0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["Device"]!) as? ContractDeviceTableViewCell {
                cell.deviceModelLabel.text = device?.model
                cell.deviceIdLabel.text = "(\(device!.id))"
                cell.versionLabel.text = device?.os_version
                currCell = cell
            }
        case (1,0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["TextField"]!) as? ContractTextFieldTableViewCell {
                cell.textField.text = "Project \(contract!.to_team)"
                currCell = cell
            }
        case (1,1):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["Employee"]!) as? ContractEmployeeTableViewCell {
                cell.employeeNameField.text = contract?.employee_name
                cell.employeeIdField.text = contract?.employee_id
                currCell = cell
            }
        case (1,2):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["TextField"]!) as? ContractTextFieldTableViewCell {
                cell.textField.text = "Since \(getFormattedDateString(fromDate: (contract?.contracted_on)!))"
                currCell = cell
            }
        case (2,0):
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellType["TextField"]!) as? ContractTextFieldTableViewCell {
                cell.textField.text = contract?.authorized_by
                currCell = cell
            }
        default:
            ()
        }
        return currCell
    }
 
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Device"
        case 1:
            return "Contracted To"
        default:
            return "Authorized By"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) {
        case (0,0):
            return 60
        default:
            return 44
        }
    }
    
    //MARK: Data Updater Delegate methods
    func updateEmployeeName(_ name: String, forCell cell: UITableViewCell) {
        if let ip = tableView.indexPath(for: cell) , ((ip as NSIndexPath).section, (ip as NSIndexPath).row) == (1, 1),
            let cell = cell as? ContractEmployeeTableViewCell {
            employeeName = cell.employeeNameField.text!
        }
    }
    
    func updateEmployeeId(_ id: String, forCell cell: UITableViewCell) {
        if let ip = tableView.indexPath(for: cell) , ((ip as NSIndexPath).section, (ip as NSIndexPath).row) == (1, 1),
            let cell = cell as? ContractEmployeeTableViewCell {
            employeeId = cell.employeeIdField.text!
        }
    }
    
    func updateTextValue(_ value: String, forCell cell: UITableViewCell) {
        if let ip = tableView.indexPath(for: cell) , ((ip as NSIndexPath).section, (ip as NSIndexPath).row) == (1, 0),
        let cell = cell as? ContractTextFieldTableViewCell {
            contractTeam = cell.textField.text!
        }
    }
    
    //MARK: Actions
    @IBAction func addContractTapped(_ sender: UIButton) {
        if newContract && isValidationSuccess() {
            createContract()
            self.waitForBlock { (activity) in
                self.contractController!.addContract { (success, message) in
                    DispatchQueue.main.async {
                        activity.stopAnimating()
                        if success {
                            OperationQueue.main.addOperation({
                                self.performSegue(withIdentifier: "contractDeviceAndReturnToPool", sender: sender)
                            })
                        }
                        else {
                            self.alertWithErrorMessage(message!)
                        }
                    }                    
                }
            }
            

            
        }
        else {
            
            let msg = "Device will be added to pool?"
            let title = "Return Device"
            alertsManager.presentActionAlert(msg, title: title, okAction: self.returnDevice, cancelAction: nil)
        }
    }
    
    func returnDevice()
    {
        self.waitForBlock { (activity) in
            contractController!.removeContract(device, contract) { (success, message) in
                self.dispatchInMain {
                    activity.stopAnimating()
                    if success {
                        self.performSegue(withIdentifier: "contractDeviceAndReturnToPool", sender: self.actionButton)
                    }
                    else {
                        self.alertWithErrorMessage(message!)
                    }
                }
            }
        }
    }
    
    func createContract() {
        //Get New Contract Id
        let contractId = Contract.getNewContractId()
        
     //   var contractDict = [String:AnyObject]()
        contractController?.id = contractId
        contractController?.to_team = self.contractTeam!
        contractController?.employee_name = self.employeeName!
        contractController?.employee_id = self.employeeId!
        contractController?.authorized_by = currentUser?.userName ?? "No Auth"
        contractController?.device_id = (self.device?.id)!
        contractController?.contracted_on = Date()
        
    }
 /*
    func saveContract(completion:(success: Bool, errorMessage: String?)->Void) -> (){
        if isValidationSuccess() {
            //Get New Contract Id
            let contractId = Contract.getNewContractId()
            
            var contractDict = [String:AnyObject]()
            contractDict["id"] = contractId
            contractDict["to_team"] = self.contractTeam!
            contractDict["employee_name"] = self.employeeName!
            contractDict["employee_id"] = self.employeeId!
            contractDict["authorized_by"] = loggedInUser!
            contractDict["device_id"] = (self.device?.id)!
            contractDict["contracted_on"] = todayDate()
            
            serviceManager.fetchRequest("/Contracts", forDataDict: contractDict, requestType: .POST) { (data, error) in
                if let error = error {
                    print("ERROR ::: \(error)")
                    completion(success: false, errorMessage: error.localizedDescription)
                    //alertsManager.presentInformationAlert("Desc: \(error.localizedDescription)", title: "Server Error")
                }
                else {
            //Create and Save the contract and, change Device Status
                    
                    self.deviceController!.updateDeviceStatus(self.device!.id, bodyDict: ["device_status": Int(DeviceFilter.InContract.rawValue), "contract_id": contractDict["contracted_on"]! ] ) { (success, errorMessage) in
                        if success {
                            Contract.createNewContract({ (newContract) in
                                self.device?.device_status = DeviceFilter.InContract.rawValue
                                self.device?.contract_id = contractId
                                
                                newContract.id = contractId
                                newContract.to_team = self.contractTeam!
                                newContract.employee_name = self.employeeName!
                                newContract.employee_id = self.employeeId!
                                newContract.authorized_by = loggedInUser!
                                newContract.device_id = (self.device?.id)!
                                newContract.contracted_on = NSDate()
                                
                                dataController.saveToPersistentStore()
                                completion(success: true, errorMessage: nil)
                            })

                        }
                        else {
                            alertsManager.presentInformationAlert(errorMessage!, title: "Server Error")
                        }
                        
                    }
                    
                }
            }
        }
    }
  */
    
        //senthil code
        func isValidationSuccess() -> Bool {
            if contractTeam == nil
            {
                alertsManager.presentInformationAlert("Enter Project Name", title: "Alert")
                return false
            }
    
            if employeeName == nil || employeeId == nil
            {
                alertsManager.presentInformationAlert("Enter Employee Name & Employee Id", title: "Alert")
                return false
            }
            
            if employeeId == nil
            {
                alertsManager.presentInformationAlert("Enter Employee Id", title: "Alert")
                return false
            }
            return true
        }
    
    
    func loadDeviceContractAsRequired() -> () {
        if let d = device, let c = Contract.getContractById(d.contract_id) {
            self.newContract = false
            self.contract = c
            actionButton.setTitle("Return Device", for: UIControlState())
        }
        else {
            self.newContract = true
        }
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
     //contractDeviceAndReturnToPool
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier , id == "contractDeviceAndReturnToPool" {
            let deviceDashboardController = segue.destination as! DeviceDashboardTableViewController
            deviceDashboardController.reloadRequired = true            
        }
    }
    

}
