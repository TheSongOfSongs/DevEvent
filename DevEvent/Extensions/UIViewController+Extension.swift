//
//  UIViewController+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit
import Toaster

extension UIViewController {
    class var identifier: String {
        return String(describing: self)
    }
    
    func showToast(_ type: ToasterMessage) {
        ToastCenter.default.cancelAll()
        
        let toast = Toast(text: type.message, duration: 3)
        toast.view.bottomOffsetPortrait = 100
        toast.show()
    }
}
