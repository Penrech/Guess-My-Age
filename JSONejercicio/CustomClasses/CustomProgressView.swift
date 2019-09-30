//
//  CustomProgressView.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 12/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import UIKit

class CustomProgressView: UIProgressView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.transform.d
    }

}
