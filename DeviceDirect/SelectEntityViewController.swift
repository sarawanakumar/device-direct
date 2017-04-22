//
//  SelectEntityViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/6/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

enum EntityType {
    case device
    case employee
}

struct DisplayEntity {
    var mainText: String
    var idText: String
    var subText: String
    var type: EntityType
    
    
    func matchesWith(_ query: String) -> Bool {
        var match = false
        match = match || mainText.lowercased().contains(query)
        match = match || idText.lowercased().contains(query)
        match = match || subText.lowercased().contains(query)
        
        return match
    }
}

class SelectEntityViewController: UITableViewController, UISearchBarDelegate {
    var deviceList: [Device]?
    var employeeList: [Employee]?
    var displayData: [DisplayEntity]?
    var allEntities: [DisplayEntity]!
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var selectedIndex: Int!
    var selectedEntity: DisplayEntity! {
        didSet {
            if let option = selectedEntity {
                selectedIndex = displayData?.index(where: { (dispEntity) -> Bool in
                    dispEntity.idText == option.idText
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(tapRecognizer)
        loadInitialEntityList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateTableViewData(forText: "")
    }
    
    @IBAction func viewTapped(_ sender: AnyObject) {
        view.endEditing(true)
    }
    func loadInitialEntityList() {
        if let devs = deviceList {
            allEntities = devs.map({ (device) -> DisplayEntity in
                return DisplayEntity(mainText: device.model!, idText: String(device.id), subText: device.os_version!, type: .device)
            })
        }
        else if let emps = employeeList {
            allEntities = emps.map({ (employee) -> DisplayEntity in
                return DisplayEntity(mainText: employee.name, idText: employee.id, subText: employee.industry!, type: .employee)
            })
        }
        else {
            allEntities = [DisplayEntity]()
        }
    }
    
    func updateTableViewData(forText searchText:String, andReload reload: Bool = true) {
        if searchText.lengthOfBytes(using: String.Encoding.utf32) > 0 {
            displayData = searchInEntity(allEntities, forText: searchText)
        }
        else {
            displayData = allEntities
        }
        if reload {
            self.tableView.reloadData()
        }
    }
    
    func searchInEntity(_ entities: [DisplayEntity], forText text: String) -> [DisplayEntity] {
        var result = [DisplayEntity]()
        
        if text.isEmpty {
            return entities
        }
        for entity in entities {
            if entity.matchesWith(text) {
                result.append(entity)
            }
        }
        return result
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("SEARCH THE DATA")
        updateTableViewData(forText: searchText.lowercased())
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
        return (displayData?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayEntityCell", for: indexPath) as? EntityTableViewCell
        cell?.bindCellWithData(displayData![(indexPath as NSIndexPath).row])
        
        if let index = selectedIndex {
            if index == (indexPath as NSIndexPath).row {
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
                
            }
            else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedIndex {
            let prevOption = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            prevOption?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.accessoryType = UITableViewCellAccessoryType.checkmark
        self.selectedEntity = displayData![(indexPath as NSIndexPath).row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "saveEntity" {
            if let selectedCell = sender as? UITableViewCell {
                let indexPathOfSelectedCell = tableView.indexPath(for: selectedCell)
                if let index = (indexPathOfSelectedCell as NSIndexPath?)?.row {
                    selectedEntity = displayData![index]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
