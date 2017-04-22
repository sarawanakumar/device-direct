//
//  DeviceTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 8/26/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet weak var deviceId: UILabel!
    @IBOutlet weak var deviceImage: UIImageView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var deviceType: UILabel!
    @IBOutlet weak var deviceOsVersion: UILabel!
    @IBOutlet weak var assignmentDetail: UILabel!
    @IBOutlet weak var withCord: UILabel!
    var cellType: DeviceFilter?
    var searchData = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindWithData(_ device: Device, inAllDevices: Bool) -> DeviceTableViewCell {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.deviceId.text = "(\(device.id))"
        self.deviceName.text = device.model
        self.deviceType.text = device.type
        self.deviceImage.image = UIImage(named: device.type!)
        self.deviceOsVersion.text = device.os_version
        
        self.cellType = DeviceFilter(rawValue: device.device_status)
        self.withCord.isHidden = true
        var cellText = ""
        
        switch self.cellType! {
        case .available:
            self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            if inAllDevices {
                cellText = "Available"
                self.selectionStyle = .default
            }
            else {
                self.assignmentDetail.isHidden = true
            }
        case .inUse:()
            self.accessoryType = UITableViewCellAccessoryType.none
            guard let accreditation = Accreditation.getAccreditation(withId: device.accreditation_id) else { return self}
            guard let employee = Employee.getEmployeeById(accreditation.employee_id) else { return self }
            cellText = "with \(employee.name) since \(getFormattedDateString(fromDate: accreditation.accredited_on!))"
            withCord.isHidden = !accreditation.with_cord
        case .inRepair:
            self.accessoryType = UITableViewCellAccessoryType.none
            if inAllDevices {
                cellText = "In Repair"
                //self.backgroundColor = UIColor.lightGrayColor()
            }
            else {
                self.assignmentDetail.isHidden = true
            }
        case .inContract:
            self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            cellText = "In Contract"
        default:
            ()
        }
        self.assignmentDetail.text = cellText
        setSearchData()
        return self
    }
    
    func setSearchData() {
        searchData = "\(deviceId.text) \(deviceName.text) \(deviceType.text) \(deviceOsVersion.text) \(assignmentDetail.text)".lowercased()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

func getFormattedDateString(fromDate date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    return formatter.string(from: date)
}

func getFormattedDateStringShort(fromDate date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM"
    return formatter.string(from: date)
}

func getDateFromString(fromString string: String) -> Date {
    let formater = DateFormatter()
    formater.dateFormat = "dd-MM-yyyy"
    return formater.date(from: string)!
}

func getOptionalDateFromString(fromString string: String) -> Date? {
    let formater = DateFormatter()
    formater.dateFormat = "dd-MM-yyyy"
    return formater.date(from: string)
}

