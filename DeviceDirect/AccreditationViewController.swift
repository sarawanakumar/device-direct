//
//  AccreditationViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/4/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class AccreditationViewController: UITableViewController {
    
    var device: Device!
    var employee: Employee!
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var deviceVersionLabel: UILabel!
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var employeeIndustryLabel: UILabel!

    @IBOutlet weak var deviceDetailsStack: UIStackView!
    @IBOutlet weak var selectDeviceLabel: UILabel!
    @IBOutlet weak var withCordSwitch: UISwitch!
    @IBOutlet weak var employeeDetailsStack: UIStackView!
    @IBOutlet weak var selectEmployeeLabel: UILabel!
    @IBOutlet weak var accreditedByLabel: UITableViewCell!
    @IBOutlet weak var accreditButton: UIButton!
    
    var accreditationController: AccreditationDataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if nil == accreditationController {
            accreditationController = AccreditationDataController()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initialViewSettings()
    }
    
    func initialViewSettings() {
        if let dev = device {
            selectDeviceLabel.isHidden = true
            deviceDetailsStack.isHidden = false
            
            //load device values
            deviceNameLabel.text = dev.model
            deviceIdLabel.text = "(\(dev.id))"
            deviceVersionLabel.text = dev.os_version
        }
        else {
            deviceDetailsStack.isHidden = true
        }
        
        if let emp = employee {
            selectEmployeeLabel.isHidden = true
            employeeDetailsStack.isHidden = false
            
            employeeNameLabel.text = emp.name
            employeeIdLabel.text = "(\(emp.id))"
            employeeIndustryLabel.text = emp.industry
        }
        else {
            employeeDetailsStack.isHidden = true
        }
        
        if currentUser!.authenticated {
            accreditedByLabel.textLabel?.text = currentUser!.userName
        }
        else {
            print("No user logged in")
        }
        
        alterAssignButtonStatus()
    }

    @IBAction func accreditDevice() {
        if let dev = device, let emp = employee {
            createAccreditation()
            self.waitForBlock { (activity) in
                self.accreditationController.addAccreditation(forDevice: dev, withEmployee: emp, withCord: self.withCordSwitch.isOn) { (success, errorMessage) in
                    self.dispatchInMain {
                        activity.stopAnimating()
                        if success {
                            self.performSegue(withIdentifier: "deviceAccredited", sender: UIButton.self)
                        } else {
                            self.alertWithErrorMessage(errorMessage!)
                        }
                    }
                }
            }
        }
        else {
            print("Select device and employee")
        }
    }
    
    func createAccreditation()
    {
        accreditationController.id = Accreditation.getNewAccreditationId()
        accreditationController.accredited_on = AccreditationDataController.todayDate()
        accreditationController.active = true
        accreditationController.authorized_by = currentUser?.userName ?? "Not Authorized"
        accreditationController.device_id = device.id
        accreditationController.employee_id = employee.id
        accreditationController.with_cord = withCordSwitch.isOn
    }
    
    @IBAction func toAccreditationController(_ segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            if id == "saveEntity" || id == "assignDevice" {
                let selectEntityController = segue.source as? SelectEntityViewController
                if let validEntity = selectEntityController?.selectedEntity {
                    switch validEntity.type {
                    case .device:
                        self.device = Device.getDeviceById(Int(validEntity.idText)!)
                    case .employee:
                        self.employee = Employee.getEmployeeById(validEntity.idText)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id == "showDevices" {
                let selectEntityController = segue.destination as? SelectEntityViewController
                selectEntityController?.deviceList = Device.getDevices(filteredBy: DeviceFilter.available)
                selectEntityController?.title = "Available Devices"
                if let dev = device {
                    selectEntityController?.selectedEntity = DisplayEntity(mainText: dev.model!, idText: String(dev.id), subText: dev.os_version!, type: .device)
                }
            }
            else if id == "showEmployees" {
                let selectEntityController = segue.destination as? SelectEntityViewController
                selectEntityController?.employeeList = Employee.getAllEmployees()
                selectEntityController?.title = "Employees"
                if let emp = employee {
                    selectEntityController?.selectedEntity = DisplayEntity(mainText: emp.name, idText: emp.id, subText: emp.industry!, type: .employee)
                }
            }
        }
    }
    
    func alterAssignButtonStatus() -> () {
        if let _ = device,
        let _ = employee{
            accreditButton.isEnabled = true
        }
        else {
            accreditButton.isEnabled = false
        }
    }

}
