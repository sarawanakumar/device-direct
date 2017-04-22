//
//  DeviceOptionTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/26/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class DeviceOptionTableViewCell: UITableViewCell, SelectionObserverDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    weak var  delegate: DeviceDataUpdaterDelegate?
    
    var optionValue: String? {
        didSet {
            valueLabel.text = optionValue
            delegate?.selectOptionChanged(forCell: self, withValue: optionValue!)
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func optionWasChangedWithValue(_ value: String) {
        optionValue = value
    }

}
