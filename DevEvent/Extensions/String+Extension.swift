//
//  String+Extension.swift
//  DevEvent
//
//  Created by Jinhyang Kim on 2022/03/06.
//

import Foundation

extension String {
    /// "XX년 XX월" 형식이 맞는지 확인
    var isEventSectionFormat: Bool {
        let array = Array(self)
        guard count == 7,
              String(array[0...1]).isNumber,
              String(array[2...3]) == "년 ",
              String(array[4...5]).isNumber,
              array[6] == "월" else {
            return false
        }
        
        return true
    }
    
    var isNumber: Bool {
        return !isEmpty
        && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
