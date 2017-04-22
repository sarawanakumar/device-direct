//
//  EmployeeTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/3/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EmployeeTableViewController: UITableViewController, UISearchBarDelegate {
    
    var employeesToPresent: [Employee]!
    var reloadRequired = false
    
    let employeeController = EmployeeDataController()

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(tapRecognizer)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alertsManager.parentController = self
        employeeSearchBar.delegate = self
        employeesToPresent = Employee.getAllEmployees()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return employeesToPresent.count
    }

    @IBAction func viewTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let empCell = tableView.dequeueReusableCell(withIdentifier: "employeeCell", for: indexPath) as? EmployeeTableViewCell {
            return empCell.bindWithEmployee(employeesToPresent[(indexPath as NSIndexPath).row])
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let emp = employeesToPresent[(indexPath as NSIndexPath).row]
        if emp.accreditations?.count > 0 {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            let message = "Employee will be removed from the List"
            let title = "Delete Employee"
            alertsManager.presentActionAlert(message, title: title, okAction: { self.deleteEmployeeWithId(indexPath) }, cancelAction: {
                OperationQueue.main.addOperation({ 
                    tableView.setEditing(false, animated: true)
                })
            })
            //self.deleteEmployeeWithId(indexPath)
        }
        return [action]
    }
    
    @IBOutlet weak var employeeSearchBar: UISearchBar!
    
    func searchBar(_ employeeSearchBar: UISearchBar, textDidChange searchText: String) {
        print("SEARCH THE DATA")
        updateTableViewData(forText: searchText.lowercased())
    }
    
    func updateTableViewData(forText searchText:String, andReload reload: Bool = true) {
        if searchText.lengthOfBytes(using: String.Encoding.utf32) > 0 {
            employeesToPresent = searchInEmployeeData(employeesToPresent, forText: searchText)
        }
        else {
            employeesToPresent = Employee.getAllEmployees()
        }
        if employeesToPresent.count < 1 {
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
        
    }
    
    func searchInEmployeeData(_ employees: [Employee], forText text: String) -> [Employee] {
        var result = [Employee]()
        if text.isEmpty {
            return employees
        }
        for employee in employees {
            if employee.matchesWith(text) {
                result.append(employee)
            }
        }
        return result
    }
    
    func getNoDataView() -> UIView? {
        return UINib(nibName: "NoDataView", bundle: nil).instantiate(withOwner: nil, options: nil)[0]
            as? UIView
    }


    func deleteEmployeeWithId(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? EmployeeTableViewCell
        
        employeeController.id = cell?.identifier
        self.waitForBlock { (activity) in
            employeeController.deleteEmployee() { (success, msg) in
                self.dispatchInMain {
                    activity.stopAnimating()
                    if success {
                        self.employeesToPresent = Employee.getAllEmployees()
                        DispatchQueue.main.async(execute: {
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        })
                    }
                    else {
                        alertsManager.presentInformationAlert("Error on Delete", title: "Error!!")
                    }
                }
            }
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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            switch id {
            case "addEmployee":
                let empDetailsController = segue.destination as! EmployeeInfoTableViewController
                empDetailsController.title = "Add Employee"
                empDetailsController.currentScope = EmployeeDetailType.new
            case "editEmployee":
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                    let empDetailsController = segue.destination as! EmployeeInfoTableViewController
                    empDetailsController.title = "Edit Employee"
                    empDetailsController.currentScope = EmployeeDetailType.existing
                    empDetailsController.employee = employeesToPresent[(indexPath as NSIndexPath).row]
                }
                
            default:
                ()
            }
        }
    }
 
    @IBAction func toEmployeeListController(_ segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            if id == "saveEmployeeAndExitToEmployeeList" {
                if reloadRequired {
                    self.employeesToPresent = Employee.getAllEmployees()
                    self.tableView.reloadData()
                    reloadRequired = false
                }
            }
        }
    }
}
