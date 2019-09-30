//
//  AccessoriesTableViewCell.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 14/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import UIKit

class AccessoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }

}
