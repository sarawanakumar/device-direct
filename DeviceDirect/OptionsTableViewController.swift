//
//  OptionsTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/2/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class OptionsTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet var optionsTableView: UITableView!
    var options: [String]!
    var allOptions : [String]!
    var optionType: OptionType!
    var optionCellIdentifier = "optionCell"
    var delegate: SelectionObserverDelegate?
    var selectedType : String = ""
    
    var deviceModelTypeController: DeviceModelTypeDataController!
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBOutlet weak var optionsSearchBar: UISearchBar!
    
    var selectedIndex: Int!
    var selectedOption: String! {
        didSet {
            if let option = selectedOption {
                selectedIndex = options.index(of: option)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionsTableView.tableHeaderView = nil
        addBtn.isEnabled = false
        allOptions = options
        
        if nil == deviceModelTypeController {
            deviceModelTypeController = DeviceModelTypeDataController()
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        alertsManager.parentController = self
        optionsSearchBar.delegate = self
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
        return options.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if let type = optionType {
            switch type {
            case .deviceModels(_):
                addBtn.isEnabled = true
                fallthrough
            case .deviceTypes:
                cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath)
            case .manager:
                cell = tableView.dequeueReusableCell(withIdentifier: optionCellIdentifier, for: indexPath)
                optionsTableView.tableHeaderView = optionsSearchBar
            case .industry:
                cell = tableView.dequeueReusableCell(withIdentifier: "employeeOptionCell", for: indexPath)
            }
            cell.textLabel?.text = options[(indexPath as NSIndexPath).row]
            cell.detailTextLabel?.text = options[(indexPath as NSIndexPath).row]
            
            if let index = selectedIndex {
                if index == (indexPath as NSIndexPath).row {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                    
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
        }        
        
        return cell
    }
    
    @IBAction func addBtnTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Device Model", message: "Enter Device Model", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let textField = alert.textFields![0] as UITextField
                let addedModel = textField.text
                if addedModel!.lengthOfBytes(using: String.Encoding.utf32) > 0{
                    self.deviceModelTypeController.device_type = self.selectedType
                    self.deviceModelTypeController.device_model = addedModel!
                    self.deviceModelTypeController.saveDeviceModel(){success, error in
                        if success {
                            self.options = DeviceModelType.getDeviceModel(self.selectedType)
                            
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })

                        }
                        else
                        {
                            alertsManager.presentInformationAlert(error!, title: "Network Error")
                        }
                    }
                    
                }
                else {
                    alertsManager.presentInformationAlert("Empty String", title: "Alert")
                }
            }))
        self.present(alert, animated: true, completion: nil)

    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedIndex {
            let prevOption = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            prevOption?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        self.selectedOption = options[(indexPath as NSIndexPath).row]
        self.delegate?.optionWasChangedWithValue(self.selectedOption)
    }
    
    func searchBar(_ optionsSearchBar: UISearchBar, textDidChange searchText: String) {
        updateTableViewData(forText: searchText.lowercased())

    }
    
    func updateTableViewData(forText searchText:String, andReload reload: Bool = true) {
        if searchText.lengthOfBytes(using: String.Encoding.utf32) > 0 {
            options = searchInDeviceData(allOptions, forText: searchText)
        }
        else {
            options = allOptions
        }
        if options.count < 1 {
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
    
    func searchInDeviceData(_ allOptions: [String], forText text: String) -> [String] {
        var result = [String]()
        if text.isEmpty {
            return allOptions
        }
        for option in options {
            if option.lowercased().contains(text) {
                result.append(option)
            }
        }
        return result
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "saveOption" || segue.identifier == "saveEmployeeOption" {
            if let selectedCell = sender as? UITableViewCell {
                let indexPathOfSelectedCell = tableView.indexPath(for: selectedCell)
                if let index = (indexPathOfSelectedCell as NSIndexPath?)?.row {
                    selectedOption = options[index]
                }
            }
        }
    }
    
    func getNoDataView() -> UIView? {
        return UINib(nibName: "NoDataView", bundle: nil).instantiate(withOwner: nil, options: nil)[0]
            as? UIView
    }

}
