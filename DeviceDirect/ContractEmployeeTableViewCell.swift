//
//  ContractEmployeeTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 10/2/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class ContractEmployeeTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var employeeNameField: UITextField!
    @IBOutlet weak var employeeIdField: UITextField!
    
    weak var delegate: DataUpdaterDelegate?
    
    var editable = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editable
    }

    @IBAction func employeeIdEdited(_ sender: UITextField) {
        delegate?.updateEmployeeId(sender.text!, forCell: self)
    }
    
    @IBAction func employeeNameEdited(_ sender: UITextField) {
        delegate?.updateEmployeeName(sender.text!, forCell: self)
    }
    
}
