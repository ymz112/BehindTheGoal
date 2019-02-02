//
//  StrUtil.swift
//
//  Created by Mingzhi Yang on 2018/12/29.
//

import Foundation

class StrUtil {
    public static func getDoubleDigitString(_ num: Int) -> String {
        if(num < 10) {
            return "0\(num)"
        }
        return "\(num)"
    }
}


