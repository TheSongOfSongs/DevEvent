//
//  UIStoryboard+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import UIKit

protocol StoryboardInstantiable {
    associatedtype MyType
    static var defaultFileName: String { get }
    static func instantiateViewController(_ bundle: Bundle?) -> MyType
}

extension StoryboardInstantiable where Self: UIViewController {
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }
    
    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName
        let sb = UIStoryboard(name: fileName, bundle: bundle)
        return sb.instantiateViewController(withIdentifier: Self.identifier) as! Self
    }
}
