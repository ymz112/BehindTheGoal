import Vapor
import MongoSwift
import HTTP



/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // initialize global state
    MongoSwift.initialize()
    
    // Connect to the database
    let client = try MongoClient(connectionString: "Your DataBase Connection String")
    let db = try client.db("myDB")
    // Goal Database
    let collection = try db.collection("myCollection")
    // Lie in Time Database(Morning)
    let morningCollection = try db.collection("Morning")
    
    // Routers for morning
    router.post("newMorning") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(MorningRequest.self).map(to: HTTPResponse.self) { morningRequest in
            
            let duplicateCheckDoc: Document = ["date": morningRequest.date, "userName": morningRequest.userName]
            let duplicateResult = try morningCollection.find(duplicateCheckDoc)
            let decoder = BSONDecoder()
            var documentsJson: Array<Any> = []
            for d in duplicateResult {
                documentsJson.append(d)
            }
            
            if(documentsJson.count == 0) {
                let doc: Document = ["date": morningRequest.date, "userName": morningRequest.userName, "wakeUpHour": morningRequest.wakeUpHour.getDoubleDigitString(),
                                     "wakeUpMinute": morningRequest.wakeUpMinute.getDoubleDigitString(), "getUpHour": morningRequest.getUpHour.getDoubleDigitString(), "getUpMinute": morningRequest.getUpMinute.getDoubleDigitString(), "lieInTime": morningRequest.lieInTime.getDoubleDigitString()]
    
                let result = try morningCollection.insertOne(doc)
                return HTTPResponse(status: .ok, body: "{msg: \"Insert Morning successful!\", result: true}")
            } else {
                try morningCollection.updateOne(filter: ["date": morningRequest.date, "userName": morningRequest.userName], update: ["$set": ["wakeUpHour": morningRequest.wakeUpHour.getDoubleDigitString(),
                                                                                                                                              "wakeUpMinute": morningRequest.wakeUpMinute.getDoubleDigitString(), "getUpHour": morningRequest.getUpHour.getDoubleDigitString(), "getUpMinute": morningRequest.getUpMinute.getDoubleDigitString(), "lieInTime": morningRequest.lieInTime.getDoubleDigitString()] as Document])
            }
            
            return HTTPResponse(status: .ok, body: "{msg: \"Update successful!\", result: true}")
        }
    }
    
    // Get the average lie in bed time
    router.get("userLieInTime", String.parameter) { req -> HTTPResponse in
        let userName = try req.parameters.next(String.self)
        let query: Document = ["userName": userName]
        let documents = try morningCollection.find(query)
        let decoder = BSONDecoder()
        var documentsJson: Array<Any> = []
        var totalLieInTime = 0
        for d in documents {
            totalLieInTime += Int("\(d["lieInTime"]!)")!
            documentsJson.append(d)
        }
        let average = (totalLieInTime == 0 || documentsJson.count == 0) ? "N/A" : (Double(totalLieInTime)/Double(documentsJson.count)).description
        
        
        return HTTPResponse(status: .ok, body: "{\n \"documents\": \(documentsJson),\n \"averageLieInTime\": \(average)\n}")
    }
    
    
    
    // Basic "It works" example
    router.get { req in
        return "It works! It's my swift backend!"
    }
    
    // Basic "Hello, world!" example
    router.get("behindTheGoal") { req in
        return "Hello, world!"
    }
    
    
    router.get("insert") { req -> String in
        let doc: Document = ["_id": 100, "a": 1, "b": 2, "c": 3]
        let result = try collection.insertOne(doc)
        return "Insert something!"
    }
    
    router.get("users", Int.parameter) { req -> String in
        let id = try req.parameters.next(Int.self)
        return "requested id #\(id)"
    }
    
    
    router.post("updateGoalName") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(GoalRequest.self).map(to: HTTPResponse.self) { goalRequest in
            try collection.updateOne(filter: ["_id": goalRequest._id], update: ["$set": ["name": goalRequest.name] as Document])
            
            return HTTPResponse(status: .ok, body: "{msg: \"Update successful!\", result: true}")
        }
    }
    
    router.post("updateGoalIsFulfilled") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(GoalRequest.self).map(to: HTTPResponse.self) { goalRequest in
            if(goalRequest.finishDate != nil && goalRequest.finishDate! != "" && goalRequest.isFulfilled == true) {
                try collection.updateOne(filter: ["_id": goalRequest._id], update: ["$set": ["isFulfilled": goalRequest.isFulfilled, "finishDate": goalRequest.finishDate ] as Document])
            } else {
                try collection.updateOne(filter: ["_id": goalRequest._id], update: ["$set": ["isFulfilled": goalRequest.isFulfilled, "finishDate": ""] as Document])
            }

            return HTTPResponse(status: .ok, body: "{ \"msg\": \"Update successful!\", \"result\": true}")
        }
    }
    
    router.get("userDocuments", String.parameter) { req -> HTTPResponse in
        let userName = try req.parameters.next(String.self)
        let query: Document = ["userName": userName]
        
        let documents = try collection.find(query)
        let decoder = BSONDecoder()
        var documentsJson: Array<Any> = []
        for d in documents {
            documentsJson.append(d)
        }
        return HTTPResponse(status: .ok, body: "\(documentsJson)")
    }
    
    router.delete("document", String.parameter) { req -> HTTPResponse in
        let _id = try req.parameters.next(String.self)
        let query: Document = ["_id": _id]
        let documents = try collection.deleteOne(query)
        return HTTPResponse(status: .ok, body: "{msg: \"Delete successful!\", result: true}")
    }
    
    router.post("addGoal") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(GoalRequest.self).map(to: HTTPResponse.self) { goalRequest in
            let doc: Document = ["_id":goalRequest._id, "name": goalRequest.name, "date": goalRequest.date, "isFulfilled": goalRequest.isFulfilled, "userName": goalRequest.userName, "category": goalRequest.category]
            let result = try collection.insertOne(doc)
            return HTTPResponse(status: .ok, body: "{msg: \"Insert successful!\", result: true}")
        }
    }
    
}


extension Int {
    public func getDoubleDigitString() -> String {
        if(self < 10) {
            return "0\(self)"
        }
        return "\(self)"
    }
}
