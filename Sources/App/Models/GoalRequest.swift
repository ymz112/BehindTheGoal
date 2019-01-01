//
//  GoalRequest
//  App
//
//  Created by 阳铭之 on 2018/12/15.
//

import Foundation
import Vapor

final class GoalRequest {
    var name: String
    var isFulfilled: Bool
    var userName: String
    var _id: String
    var date: String

    public init(_id: String, name: String, isFulfilled: Bool, userName: String, date: String){
        self._id = _id
        self.name = name
        self.isFulfilled = isFulfilled
        self.userName =  userName
        self.date = date
    }
}

extension GoalRequest: Content {}
