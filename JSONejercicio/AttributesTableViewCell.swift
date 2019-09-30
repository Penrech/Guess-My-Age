//
//  AttributesTableViewCell.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 13/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import UIKit

class AttributesTableViewCell: UITableViewCell {

    @IBOutlet weak var iconForLabel: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
