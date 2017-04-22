//
//  AllAccreditationsTableViewController.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/18/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

struct AccreditationModel {
    var accId: Int?
    var accDate: String?
    var retDate: String?
    var devModel: String?
    var devId: Int?
    var empName: String?
    var empId: String?
    var model: String?
    //var accreditation: Accreditation?
    //var device: Device?
    //var employee: Employee?
}

class AllAccreditationsTableViewController: UITableViewController, UISearchBarDelegate{
    var accreditationsToPresent: [String:[AccreditationModel]]?
    var allAccreditation: [Accreditation]?
    var filteredAccreditation: [Accreditation]?
    var sectionList: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(tapRecognizer)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBAction func viewTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var accreditationSearchBar: UISearchBar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allAccreditation = Accreditation.getAllAccreditations(byAscending: false)
        accreditationsToPresent = Accreditation.accreditationModelMapper(allAccreditation!)
        sectionList = accreditationsToPresent?.keys.sorted { first, second in
            let f = getDateFromString(fromString: first).timeIntervalSinceNow
            let s = getDateFromString(fromString: second).timeIntervalSinceNow
            return f > s
        }
        accreditationSearchBar.delegate = self
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return accreditationsToPresent?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return (accreditationsToPresent?.count)!
        sectionList = accreditationsToPresent?.keys.sorted { first, second in
            let f = getDateFromString(fromString: first).timeIntervalSinceNow
            let s = getDateFromString(fromString: second).timeIntervalSinceNow
            return f > s
        }

        return accreditationsToPresent![sectionList![section]]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionList![section]
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "accreditationCell", for: indexPath) as? AccreditationTableViewCell {
            //return cell.bindWithModel(accreditationsToPresent![indexPath.row])
            let accModels = accreditationsToPresent![sectionList![(indexPath as NSIndexPath).section]]
            return cell.bindWithModel(accModels![(indexPath as NSIndexPath).row])
        }

        // Configure the cell...

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    

    func searchBar(_ accreditationSearchBar: UISearchBar, textDidChange searchText: String) {
        print("SEARCH THE DATA")
        updateTableViewData(forText: searchText.lowercased())
    }
    
    func updateTableViewData(forText searchText:String, andReload reload: Bool = true) {
        if searchText.lengthOfBytes(using: String.Encoding.utf32) > 0 {
            filteredAccreditation = searchInAccrediationData(allAccreditation!, forText: searchText)
            accreditationsToPresent = Accreditation.accreditationModelMapper(filteredAccreditation!)
        }
        else {
            //  filteredAccreditation = Accreditation.getAllAccreditations(byAscending: false)
            accreditationsToPresent = Accreditation.accreditationModelMapper(allAccreditation!)
        }
        if accreditationsToPresent!.count < 1 {
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
    
    func searchInAccrediationData(_ accreditations: [Accreditation], forText text: String) -> [Accreditation] {
        var result = [Accreditation]()
        if text.isEmpty {
            return accreditations
        }
        for accreditation in accreditations {
            let empName = Employee.employeeNameForId(accreditation.employee_id)?.lowercased()
            let searchText = String(accreditation.device_id) + String(accreditation.employee_id.lowercased()) + String(empName!)
            if searchText.contains(text) {
                result.append(accreditation)
            }
        }
        return result
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
