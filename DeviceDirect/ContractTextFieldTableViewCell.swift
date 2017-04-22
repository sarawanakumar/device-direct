//
//  ContractTextFieldTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 10/2/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class ContractTextFieldTableViewCell: UITableViewCell, UITextFieldDelegate {
    var editable = false
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: DataUpdaterDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func textChanged(_ sender: AnyObject) {
        delegate?.updateTextValue(((sender as? UITextField)?.text)!, forCell: self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return editable
    }

}
