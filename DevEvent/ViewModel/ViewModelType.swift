//
//  ViewModelType.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/05.
//

import Foundation

protocol ViewModelType: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
