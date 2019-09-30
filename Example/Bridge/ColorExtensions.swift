//
//  ColorExtensions.swift
//  Bridge_Example
//
//  Created by Alexey Pichukov on 30/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var random: UIColor {
        return .init(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 1)
    }
    
}
