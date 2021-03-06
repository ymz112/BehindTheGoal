//
//  GoalRequest
//  App
//
//  Created by ymz on 2018/12/15.
//

import Foundation
import Vapor

final class GoalRequest {
    var name: String
    var isFulfilled: Bool
    var userName: String
    var _id: String
    var date: String
    var finishDate: String?
    var category: String?

    public init(_id: String, name: String, isFulfilled: Bool, userName: String, date: String, finishDate: String = "", category: String = ""){
        self._id = _id
        self.name = name
        self.isFulfilled = isFulfilled
        self.userName =  userName
        self.date = date
        self.finishDate = finishDate
        self.category = category
    }
}

extension GoalRequest: Content {}
