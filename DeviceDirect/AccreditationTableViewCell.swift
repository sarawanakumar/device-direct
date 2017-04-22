//
//  AccreditationTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/18/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class AccreditationTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceModelLabel: UILabel!
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var employeeNameLabel: UILabel!
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var accreditationImageView: UIImageView!
    @IBOutlet weak var accreditationIdLabel: UILabel!
    @IBOutlet weak var deviceImageView: UIImageView!
    
    var deviceModel: String! {
        didSet{
            if let lbl = deviceModel {
                deviceModelLabel.text = lbl
            }
            else {
                deviceModelLabel.text = "<Unknown>"
            }
        }
    }
    
    var deviceId: Int! {
        didSet {
            if let id = deviceId {
                deviceIdLabel.text = "(\(id))"
            }
            else {
                deviceIdLabel.text = ""
            }
        }
    }
    
    var employeeName: String! {
        didSet {
            if let name = employeeName {
                employeeNameLabel.text = "Accredit: \(name)"
            }
            else {
                employeeNameLabel.text = "<Unknown>"
            }
        }
    }
    
    var status: String! {
        didSet {
            if let stat = status {
                statusLabel.text = "Returned " + stat
                accreditationImageView.backgroundColor = UIColor.green
                //accreditationImageView.image = UIImage(named: "green")
            }
            else {
                statusLabel.text = "Yet to return"
                accreditationImageView.backgroundColor = UIColor.red
                //accreditationImageView.image = UIImage(named: "red")
            }
        }
    }
    
    var employeeId: String! {
        didSet {
            if let id = employeeId {
                employeeIdLabel.text = "(\(id))"
            }
            else {
                employeeIdLabel.text = ""
            }
        }
    }
    
    var accreditationId: Int! {
        didSet {
            if let id = accreditationId {
                accreditationIdLabel.text = "\(id)"
            }
            else {
                accreditationIdLabel.text = "None"
            }
        }
    }
    
    var devImage: String! {
        didSet {
            if let name = devImage {
                deviceImageView.image = UIImage(named: name)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accreditationImageView.layer.cornerRadius = accreditationImageView.bounds.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindWithModel(_ model: AccreditationModel) -> AccreditationTableViewCell {
        /*deviceModelLabel.text = model.devModel //model.device?.model
        deviceIdLabel.text = "(\(model.devId))" //"(\(model.device?.id))"
        employeeNameLabel.text = model.empName //model.employee?.name
        employeeIdLabel.text = "(\(model.empId))" //model.employee?.id
        statusLabel.text = model.accDate //getFormattedDateString(fromDate: (model.accreditation?.accredited_on)!)*/
        deviceModel = model.devModel
        deviceId = model.devId
        employeeName = model.empName
        employeeId = model.empId
        status = model.retDate
        accreditationId = model.accId
        devImage = model.model
        selectionStyle = .none
        return self
    }

}
