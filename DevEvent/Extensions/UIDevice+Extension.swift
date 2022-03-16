//
//  UIDevice+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/15.
//

import AVFoundation
import UIKit

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(1519)
    }
}
