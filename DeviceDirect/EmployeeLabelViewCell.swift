//
//  EmployeeLabelViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/20/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class EmployeeLabelViewCell: UITableViewCell {

    @IBOutlet weak var employeeInfoLabel: UILabel!
    @IBOutlet weak var accreditationIndicator: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
