//
//  EmployeeOptionViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/20/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

protocol SelectionObserverDelegate {
    func optionWasChangedWithValue(_ value: String)
}

class EmployeeOptionViewCell: UITableViewCell, SelectionObserverDelegate {

    weak var delegate: EmployeeInfoObserverDelegate?
    @IBOutlet weak var optionNameLabel: UILabel!
    @IBOutlet weak var optionValueLabel: UILabel!
    
    var optionValue: String? {
        didSet {
            optionValueLabel.text = optionValue
            delegate?.updateOptionValue(forCell: self, withValue: optionValue)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func optionWasChangedWithValue(_ value: String) {
        optionValue = value
    }

}
