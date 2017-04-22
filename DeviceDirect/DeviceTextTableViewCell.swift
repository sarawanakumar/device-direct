//
//  DeviceTextTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/26/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class DeviceTextTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var deviceTextField: UITextField!
    var editable = true
    
    weak var  delegate: DeviceDataUpdaterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func textEdited(_ sender: UITextField) {
        delegate?.textValueChanged(forCell: self, withValue: sender.text!)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editable
    }
}
