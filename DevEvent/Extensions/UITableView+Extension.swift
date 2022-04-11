//
//  UITableView+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/04/08.
//

import UIKit

extension UITableView {
    var isEmpty: Bool {
        for i in 0..<numberOfSections where numberOfRows(inSection: i) > 0 {
            return false
        }
        
        return true
    }
}
