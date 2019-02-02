//
//  MorningRequest.swift
//
//  Created by Mingzhi Yang on 2018/12/20.
//

import Foundation
import Vapor


final class MorningRequest: NSObject {
    var date: String
    var wakeUpHour: Int
    var wakeUpMinute: Int
    var getUpHour: Int
    var getUpMinute: Int
    var userName: String
    var lieInTime: Int

    override var description: String {
        return "{userName: \(userName), date: \(date), wakeUpHour: \(wakeUpHour), wakeUpMinute: \(wakeUpMinute), getUpHour: \(getUpHour), getUpMinute: \(getUpMinute), lieInTime: \(lieInTime)}"
    }
    
    public init(date: String, userName: String, wakeUpHour: Int, wakeUpMinute: Int, getUpHour: Int, getUpMinute: Int, lieInTime: Int) {
        
        self.date = date
        self.userName = userName
        self.wakeUpHour = wakeUpHour
        self.wakeUpMinute = wakeUpMinute
        self.getUpHour = getUpHour
        self.getUpMinute = getUpMinute
        self.lieInTime = lieInTime
        super.init()
    }
}

extension MorningRequest: Content {}
