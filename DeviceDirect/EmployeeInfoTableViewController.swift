//
//  EmployeeInfoTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/20/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

enum EmployeeDetailType {
    case new
    case existing
}

//Delegate for notifying the ViewController if a cell has been altered
protocol EmployeeInfoObserverDelegate: class {
    func updateTextValue(forCell cell: UITableViewCell,withValue value: String?)
    func updateOptionValue(forCell cell: UITableViewCell,withValue value: String?)
}

class EmployeeInfoTableViewController: UITableViewController, EmployeeInfoObserverDelegate {
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var employeeController: EmployeeDataController?
    var currentScope: EmployeeDetailType?
    var employee: Employee?
    
    var employeeName: String? {
        willSet {
            employeeController?.name = newValue
        }
    }
    
    var employeeId: String? {
        willSet {
            employeeController?.id = newValue
        }
    }
    
    var projectName: String? {
        willSet {
            employeeController?.project = newValue
        }
    }
    var industryName: String? {
        willSet {
            employeeController?.industry = newValue
        }
    }
    
    var email: String? {
        willSet {
            employeeController?.email = newValue
        }
    }
    
    
    let cellIds = ["Text": "empTextFieldCell", "Option": "empSelectOptionCell", "Label": "empLabelCell"]
    let sectionHeader = ["Employee Details", "Project Details", "Accreditations"]
    
    var selectedIndustry: String?
    
    //MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(tapRecognizer)
        alertsManager.parentController = self
        if nil == employeeController {
            employeeController = EmployeeDataController()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func viewTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let scope = currentScope {
            switch scope {
            case .new:
                return 2
            case .existing:
                return 3
            }
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 2
        case 2:
            if let e = employee, let a = e.accreditations , a.count > 0 {
                return a.count
            }
            return 1
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ip = ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row)
        
        if let anEmp = employee , currentScope == EmployeeDetailType.existing {
            switch ip {
            case (0,0):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.text = anEmp.name
                self.employeeName = anEmp.name
                cell.fieldEditable = false
                cell.delegate = self
                return cell
            case (0,1):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.text = anEmp.id
                self.employeeId = anEmp.id
                cell.fieldEditable = false
                cell.delegate = self
                return cell
            case (0,2):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.text = anEmp.email_id ?? ""
                self.email = anEmp.email_id
                cell.fieldEditable = false
                cell.delegate = self
                return cell
            case (1,0):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.placeholder = "Project Name"
                cell.employeeInfoField.text = anEmp.project ?? "None"
                self.projectName = anEmp.project ?? "None"
                cell.delegate = self
                return cell
            case (1,1):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Option"]!, for: indexPath) as! EmployeeOptionViewCell
                cell.optionNameLabel.text = "Industry"
                cell.optionValueLabel.text = selectedIndustry ?? anEmp.industry
                self.industryName = selectedIndustry ?? anEmp.industry
                selectedIndustry = anEmp.industry
                cell.delegate = self
                return cell
            case (2,let x):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Label"]!, for: indexPath) as! EmployeeLabelViewCell
                if let accs = anEmp.accreditations , accs.count > 0 {
                    if let accred = Accreditation.getAccreditation(withId: accs[x]), let dev = Device.getDeviceById(accred.device_id) {
                        cell.employeeInfoLabel.text = "\(dev.model ?? "<No Name>") (\(dev.id)) since \(getFormattedDateString(fromDate: accred.accredited_on!))"
                        return cell
                    }
                }
                else {
                    cell.employeeInfoLabel.text = "No active accreditations"
                    cell.employeeInfoLabel.textAlignment = .center
                    cell.accreditationIndicator.isHidden = true
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
        else {
            switch ip {
            case (0,0):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.placeholder = "Employee Name"
                cell.delegate = self
                return cell
            case (0,1):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.placeholder = "Employee Id"
                cell.delegate = self
                return cell
            case (0,2):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.placeholder = "Email Id"
                cell.delegate = self
                return cell
            case (1,0):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Text"]!, for: indexPath) as! EmployeeTextViewCell
                cell.employeeInfoField.placeholder = "Project Name"
                cell.delegate = self
                return cell
            case (1,1):
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIds["Option"]!, for: indexPath) as! EmployeeOptionViewCell
                cell.optionNameLabel.text = "Industry"
                cell.optionValueLabel.text = selectedIndustry ?? "Select an Industry"
                cell.delegate = self
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeader[section]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row) == (1,1) {
            performSegue(withIdentifier: "selectIndustry", sender: tableView.cellForRow(at: indexPath))
        }
    }
    
    
    //MARK: Instance methods (helper)
    var isValidationSuccess: Bool {
        var valid = false
        var message: String?
        let title = "Save Error"
        if employeeName == nil || employeeName == "" {
            valid = false
            message = "Employee name cannot be empty."
        }
        else if employeeId == nil || employeeId == "" {
            valid = false
            message = "Employee Id cannot be empty."
        }
        else if let _ = Employee.getEmployeeById(employeeId!) {
            valid = false
            message = "Employee with Id already exists."
        }
        else if projectName == nil || projectName == "" {
            valid = false
            message = "Project Name cannot be empty."
        }
        else if industryName == nil {
            valid = false
            message = "Industry must be chosen."
        }
        else {
            valid = true
        }
        if let m = message {
            alertsManager.presentInformationAlert(m, title: title)
        }
        return valid
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "selectIndustry":
                let optionsContoller = segue.destination as? OptionsTableViewController
                optionsContoller?.title = "Device Types"
                optionsContoller?.delegate = sender as? EmployeeOptionViewCell
                optionsContoller?.optionType = OptionType.industry
                optionsContoller?.options = industry
                optionsContoller?.selectedOption = selectedIndustry
            case "saveEmployeeAndExitToEmployeeList":
                let empListContoller = segue.destination as! EmployeeTableViewController
                empListContoller.reloadRequired = true
            default:
                ()
            }
        }
    }
    
    @IBAction func saveEmployeeAndReturn(_ sender: UIBarButtonItem) {
        switch currentScope! {
        case .existing:
            var updateDict = [String:AnyObject]()
            if let proj = projectName , proj != employee?.project {
                if proj.isEmpty {
                    alertsManager.presentInformationAlert("Project Name cannot be empty.", title: "Save Error")
                }
                else {
                   updateDict["project"] = projectName! as AnyObject
                    self.employee?.project = self.projectName
                }
            }
            if let ind = industryName , ind != employee?.industry {
                updateDict["industry"] = industryName! as AnyObject
                self.employee?.industry = self.industryName
            }
            if updateDict.count > 0 {
                self.waitForBlock { (activityIndicator) in
                    employeeController!.updateEmployee(with: updateDict) { (success, message) in
                        self.dispatchInMain {
                            activityIndicator.stopAnimating()
                            if success {
                                dataController.saveToPersistentStore { err in
                                    if let e = err {
                                        alertsManager.presentLogoutAlert(e)
                                    }
                                    else {
                                        self.performSegue(withIdentifier: "saveEmployeeAndExitToEmployeeList", sender: nil)
                                    }
                                }
                            }
                            else {
                                dataController.context.reset()
                                self.alertWithErrorMessage(message!)
                            }
                        }
                    }
                }
            }
            else {
                OperationQueue.main.addOperation {
                    self.performSegue(withIdentifier: "saveEmployeeAndExitToEmployeeList", sender: nil)
                }
            }
        case .new:
            if isValidationSuccess {
                self.waitForBlock { (activity) in
                    employeeController!.createAndSaveEmployee { (success, message) in
                        self.dispatchInMain {
                            activity.stopAnimating()
                            if success {
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "saveEmployeeAndExitToEmployeeList", sender: nil)
                                }
                            }
                            else {
                                self.alertWithErrorMessage(message!)
                            }
                        }
                    }
                }                
            }
        }
    }
    
    @IBAction func toEmployeeInfo(_ segue: UIStoryboardSegue) {
        if segue.identifier == "saveEmployeeOption" {
            let optionsController = segue.source as? OptionsTableViewController
            let option = optionsController!.optionType
            switch option {
            case .some(OptionType.industry):
                selectedIndustry = optionsController?.selectedOption
            default:
                ()
            }
        }
    }
    
    //MARK: Delegate methods
    func updateTextValue(forCell cell: UITableViewCell,withValue value: String?) {
        if let ip = tableView.indexPath(for: cell) {
            switch ((ip as NSIndexPath).section, (ip as NSIndexPath).row) {
            case (0,0):
                employeeName = value
            case (0,1):
                employeeId = value
            case (0,2):
                email = value
            case (1,0):
                projectName = value
            default:
                ()
            }
        }
    }
    
    func updateOptionValue(forCell cell: UITableViewCell,withValue value: String?) {
        if let ip = tableView.indexPath(for: cell) , ((ip as NSIndexPath).section,(ip as NSIndexPath).row) == (1,1) {
            industryName = value
        }
    }
    
    //MARK: API Methods
    
}
