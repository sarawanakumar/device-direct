//
//  EmployeeTextViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/20/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class EmployeeTextViewCell: UITableViewCell, UITextFieldDelegate {

    weak var delegate: EmployeeInfoObserverDelegate?
    @IBOutlet weak var employeeInfoField: UITextField!
    var fieldEditable: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        delegate?.updateTextValue(forCell: self, withValue: sender.text)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return fieldEditable
    }
    

}
