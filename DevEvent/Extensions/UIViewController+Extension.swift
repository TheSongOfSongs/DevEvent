//
//  UIViewController+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit

extension UIViewController {
    class var identifier: String {
        return String(describing: self)
    }
}
