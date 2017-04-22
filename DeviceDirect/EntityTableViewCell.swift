//
//  EntityTableViewCell.swift
//  DeviceDirect
//
//  Created by kumarsaravana on 9/6/16.
//  Copyright © 2016 ibm. All rights reserved.
//

import UIKit

class EntityTableViewCell: UITableViewCell {

    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var idTextLabel: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindCellWithData(_ entity: DisplayEntity) -> EntityTableViewCell {
        mainTextLabel.text = entity.mainText
        idTextLabel.text = "(\(entity.idText))"
        subTextLabel.text = entity.subText
        return self
    }
}
