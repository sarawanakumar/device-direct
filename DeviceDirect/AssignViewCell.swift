//
//  AssignViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/18/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class AssignViewCell: UITableViewCell {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var empNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindWithData(_ accr: Accreditation) -> AssignViewCell {
        deviceNameLabel.text = Device.deviceModelForId(accr.device_id)
        empNameLabel.text = Employee.employeeNameForId(accr.employee_id)
        dateLabel.text = getFormattedDateStringShort(fromDate: accr.accredited_on ?? Date())
        
        self.backgroundColor = UIColor.clear //UIColor(red: 249.0/255.0, green: 162.0/255.0, blue: 11.0/255.0, alpha: 1.0)
        return self
    }

}
