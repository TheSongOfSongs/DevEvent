//
//  UIView+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import UIKit

extension UIView {
    class var identifier: String {
        return String(describing: self)
    }
    
    func makeCornerRounded(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
