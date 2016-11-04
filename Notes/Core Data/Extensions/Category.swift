//
//  Category.swift
//  Notes
//
//  Created by Bart Jacobs on 04/11/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import Foundation

extension Category {

    var color: UIColor? {
        get {
            guard let hex = colorAsHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                colorAsHex = newColor.toHex
            }
        }
    }

}
