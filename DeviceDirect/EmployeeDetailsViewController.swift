//
//  EmployeeDetailsViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/8/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit



class EmployeeDetailsViewController: UITableViewController, UITextFieldDelegate {
    var currentScope: EmployeeDetailType?
    var employee: Employee?
    
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var managerLabel: UILabel!
    @IBOutlet weak var employeeIdTextField: UITextField!
    @IBOutlet weak var employeeNameTextField: UITextField!
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var accreditationsLabel: UILabel!
    
    @IBOutlet var dismissKeyboardRecognizer: UITapGestureRecognizer!
    var selectedIndustry: String? {
        didSet {
            industryLabel.text = selectedIndustry
        }
    }
    var selectedManager: String? {
        didSet {
            managerLabel.text = selectedManager
        }
    }
    
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add tap gesture
        self.view.addGestureRecognizer(dismissKeyboardRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadInitialData()
        //accreditationsView.backgroundColor = UIColor.orangeColor()
    }
    
    func loadInitialData() {
        if let emp = employee {
            employeeIdTextField.text = emp.id
            employeeNameTextField.text = emp.name
            projectNameTextField.text = emp.project
            if nil == selectedIndustry {
                selectedIndustry = emp.industry
            }
            if nil == selectedManager {
                selectedManager = emp.manager
            }
            
            if let accs = emp.accreditations , accs.count > 0 {
                accreditationsLabel.text = "Holding \(accs.count) device(s)"
            }
            else {
                accreditationsLabel.text = "No accreditations"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        if currentScope == EmployeeDetailType.new {
            return 2
        }
        else if currentScope == EmployeeDetailType.existing {
            return 3
        }
        else {
            return 0
        }
    }
    
    @IBAction func toEmployeeDetail(_ segue: UIStoryboardSegue) {
        if segue.identifier == "saveEmployeeOption" {
            let optionsController = segue.source as? OptionsTableViewController
            let option = (optionsController?.optionType)!
            switch option {
            case OptionType.industry:
                selectedIndustry = optionsController?.selectedOption
            case OptionType.manager:
                selectedManager = optionsController?.selectedOption
            default:
                ()
            }
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "saveEmployeeAndExitToEmployeeList" {
            if !isValidationSuccess() {
                return false
            }
        }
        return true
    }
    
    func isValidationSuccess() -> Bool {
        if employeeIdTextField.text == "" || employeeNameTextField.text == ""
        {
            alertsManager.presentInformationAlert("Enter Employee Id and Name", title: "Alert")
            return false
        }
        
        if projectNameTextField.text == ""
        {
            alertsManager.presentInformationAlert("Enter Project Name", title: "Alert")
            return false
        }
        if selectedIndustry == nil
        {
            alertsManager.presentInformationAlert("Select Industry", title: "Alert")
            return false
        }
        if selectedManager == nil
        {
            alertsManager.presentInformationAlert("Select Manager", title: "Alert")
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "selectIndustry":
                let optionsContoller = segue.destination as? OptionsTableViewController
                optionsContoller?.title = "Device Types"
                optionsContoller?.optionType = OptionType.industry
                optionsContoller?.options = industry
                optionsContoller?.selectedOption = selectedIndustry
            case "selectManager":
                let optionsContoller = segue.destination as? OptionsTableViewController
                optionsContoller?.title = "Device Models"
                optionsContoller?.optionType = OptionType.manager
                optionsContoller?.options = manager
                optionsContoller?.selectedOption = selectedManager
                
            case "temp":
                let empInfoController = segue.destination as! EmployeeInfoTableViewController
                //empInfoController.employee = employee
                empInfoController.currentScope = .some(EmployeeDetailType.new)
                
            case "saveEmployeeAndExitToEmployeeList":
                let empListContoller = segue.destination as! EmployeeTableViewController
                empListContoller.reloadRequired = true
                if currentScope == .new {
                    Employee.createEmployee({ (emp) in
                        emp.id = self.employeeIdTextField.text!
                        emp.name = self.employeeNameTextField.text!
                        emp.project = self.projectNameTextField.text
                        emp.industry = self.selectedIndustry
                        emp.manager = self.selectedManager
                        emp.active = true
                        //dataController.saveToPersistentStore()
                    })
                }
                else if currentScope == .existing {
                    if let _ = employee {
                        employee!.project = self.projectNameTextField.text
                        employee!.industry = self.selectedIndustry
                        employee!.manager = self.selectedManager
                        
                        //dataController.saveToPersistentStore()
                    }
                    else {
                        print("error")
                    }
                    
                }
            default:
                ()
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if currentScope == EmployeeDetailType.new {
            return true
        }
        else if textField == projectNameTextField {
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == employeeIdTextField {
            employeeNameTextField.becomeFirstResponder()
        }
        else if textField == employeeNameTextField {
            projectNameTextField.becomeFirstResponder()
        }
        else if textField == projectNameTextField {
            projectNameTextField.resignFirstResponder()
        }
        return true
    }
}
