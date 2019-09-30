//
//  UIApplication+Ext.swift
//  RestaurantesCice2
//
//  Created by Pau Enrech on 26/02/2019.
//  Copyright © 2019 Enrech. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}
