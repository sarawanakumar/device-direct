//
//  ContractDeviceTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 10/2/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class ContractDeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceModelLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
