//
//  EmployeeTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/3/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class EmployeeTableViewCell: UITableViewCell {
    
    var identifier: String?
    @IBOutlet weak var empProfileImage: UIImageView!
    @IBOutlet weak var empNameLabel: UILabel!
    @IBOutlet weak var empIdLabel: UILabel!
    @IBOutlet weak var empIndustryLabel: UILabel!
    @IBOutlet weak var empProjectLabel: UILabel!
    @IBOutlet weak var empManagerLabel: UILabel!
    @IBOutlet weak var empAccreditStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindWithEmployee(_ employee: Employee) -> EmployeeTableViewCell {
        self.empProfileImage.image = UIImage(named: "profile_pic")
        self.empProfileImage.layer.cornerRadius = self.empProfileImage.bounds.width/2
        self.empProfileImage.layer.masksToBounds = true
        //self.empProfileImage.backgroundColor = UIColor.orangeColor()
        //self.empProfileImage.image = UIImage(named: "")
        self.empNameLabel.text = employee.name
        self.identifier = employee.id
        self.empIdLabel.text = "(\(employee.id))"
        self.empIndustryLabel.text = employee.industry
        //self.empProjectLabel.text = employee.project
        //self.empManagerLabel.text = employee.manager
        
        self.empAccreditStatus.text = (employee.accreditations?.count > 0) ? "holding \(employee.accreditations!.count) device(s)" : ""
        
        return self
    }

}
