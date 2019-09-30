//
//  String+Ext.swift
//  JSONejercicio
//
//  Created by Pau Enrech on 14/03/2019.
//  Copyright © 2019 Pau Enrech. All rights reserved.
//

import Foundation
import UIKit

extension String{
    //Estas funciones formatean un String de modo que la primera letra sea Uppercase
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
