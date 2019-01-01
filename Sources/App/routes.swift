import Vapor
import MongoSwift
import SwiftyJSON
import HTTP


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // initialize global state
    MongoSwift.initialize()
    
    let client = try MongoClient(connectionString: "mongodb://Goalden:Goalden123@goalden-shard-00-00-etr2n.mongodb.net:27017,goalden-shard-00-01-etr2n.mongodb.net:27017,goalden-shard-00-02-etr2n.mongodb.net:27017/test?ssl=true&replicaSet=Goalden-shard-0&authSource=admin&retryWrites=true")
    let db = try client.db("myDB")
    // Goal Database
    let collection = try db.collection("myCollection")
    // Lie in Time Database(Morning)
    let morningCollection = try db.collection("Morning")
    
    // Routers for morning
    router.post("newMorning") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(MorningRequest.self).map(to: HTTPResponse.self) { morningRequest in
            print("Date: \(morningRequest.date)")
            print("UserName: \(morningRequest.userName)")
            print("\(morningRequest.description)")
            
            let duplicateCheckDoc: Document = ["date": morningRequest.date, "userName": morningRequest.userName]
            let duplicateResult = try morningCollection.find(duplicateCheckDoc)
            let decoder = BSONDecoder()
            var documentsJson: Array<JSON> = []
            for d in duplicateResult {
                let json = try decoder.decode(JSON.self, from: d)
                documentsJson.append(json)
            }
            print("duplicate result length: \(documentsJson.count)")
            
            if(documentsJson.count == 0) {
                let doc: Document = ["date": morningRequest.date, "userName": morningRequest.userName, "wakeUpHour": morningRequest.wakeUpHour.getDoubleDigitString(),
                                     "wakeUpMinute": morningRequest.wakeUpMinute.getDoubleDigitString(), "getUpHour": morningRequest.getUpHour.getDoubleDigitString(), "getUpMinute": morningRequest.getUpMinute.getDoubleDigitString(), "lieInTime": morningRequest.lieInTime.getDoubleDigitString()]
    
                let result = try morningCollection.insertOne(doc)
                print(result?.insertedId ?? "")
                return HTTPResponse(status: .ok, body: "Insert new morning successful!")
            }
            
            try morningCollection.updateOne(filter: ["date": morningRequest.date, "userName": morningRequest.userName], update: ["$set": ["wakeUpHour": morningRequest.wakeUpHour.getDoubleDigitString(),
                                                                                                                                          "wakeUpMinute": morningRequest.wakeUpMinute.getDoubleDigitString(), "getUpHour": morningRequest.getUpHour.getDoubleDigitString(), "getUpMinute": morningRequest.getUpMinute.getDoubleDigitString(), "lieInTime": morningRequest.lieInTime.getDoubleDigitString()] as Document])
            
            return HTTPResponse(status: .ok, body: "Update successful!")
        }
    }
    
    // Get the average lie in bed time
    router.get("userLieInTime", String.parameter) { req -> HTTPResponse in
        let userName = try req.parameters.next(String.self)
        let query: Document = ["userName": userName]
        let documents = try morningCollection.find(query)
        let decoder = BSONDecoder()
        var documentsJson: Array<JSON> = []
        var totalLieInTime = 0
        for d in documents {
            let json = try decoder.decode(JSON.self, from: d)
            totalLieInTime += json["lieInTime"].intValue
            documentsJson.append(json)
        }
        let average = (totalLieInTime == 0 || documentsJson.count == 0) ? "N/A" : (Double(totalLieInTime)/Double(documentsJson.count)).description
        
        
        return HTTPResponse(status: .ok, body: "{\n \"documents\": \(JSON(documentsJson)),\n \"averageLieInTime\": \(average)\n}")
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
        print(result?.insertedId ?? "") // prints `100`
        return "Insert something!"
    }
    
    router.get("users", Int.parameter) { req -> String in
        let id = try req.parameters.next(Int.self)
        return "requested id #\(id)"
    }
    
//    router.get("goals") { req -> Goal in
//        return Goal(name: "Study", createdAt: "123", isFulfilled: false)
//    }
    
    router.post("updateGoalName") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(GoalRequest.self).map(to: HTTPResponse.self) { goalRequest in
            try collection.updateOne(filter: ["_id": goalRequest._id], update: ["$set": ["name": goalRequest.name] as Document])
            
            return HTTPResponse(status: .ok, body: "Update successful!")
        }
    }
    
    router.post("updateGoalIsFulfilled") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(GoalRequest.self).map(to: HTTPResponse.self) { goalRequest in
            try collection.updateOne(filter: ["_id": goalRequest._id], update: ["$set": ["isFulfilled": goalRequest.isFulfilled] as Document])
            
            return HTTPResponse(status: .ok, body: "Update successful!")
        }
    }
    
    router.get("userDocuments", String.parameter) { req -> HTTPResponse in
        let userName = try req.parameters.next(String.self)
        let query: Document = ["userName": userName]
        
        let documents = try collection.find(query)
        let decoder = BSONDecoder()
        var documentsJson: Array<JSON> = []
        for d in documents {
            let json = try decoder.decode(JSON.self, from: d)
            documentsJson.append(json)
        }
        return HTTPResponse(status: .ok, body: "\(JSON(documentsJson))")
    }
    
    router.delete("document", String.parameter) { req -> HTTPResponse in
        let _id = try req.parameters.next(String.self)
        let query: Document = ["_id": _id]
        let documents = try collection.deleteOne(query)
        return HTTPResponse(status: .ok, body: "Delete Success!")
    }
    
//    func getGoalsByUser(userName: String) {
//        let query: Document = ["userName": userName]
//        let documents = try collection.find(query)
//        for d in documents {
//            print(d)
//        }
//    }
    
    router.post("addGoal") { req -> Future<HTTPResponse> in
        
        return try req.content.decode(GoalRequest.self).map(to: HTTPResponse.self) { goalRequest in
            print("Name: \(goalRequest.name)")
            print("Type of isFulfilled: \(type(of: goalRequest.isFulfilled) )")
            let doc: Document = ["_id":goalRequest._id, "name": goalRequest.name, "date": goalRequest.date, "isFulfilled": goalRequest.isFulfilled, "userName": goalRequest.userName]
            let result = try collection.insertOne(doc)
            print(result?.insertedId ?? "")


            return HTTPResponse(status: .ok, body: "Insert successful!")
        }
    }
    
    

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}


extension Int {
    public func getDoubleDigitString() -> String {
        if(self < 10) {
            return "0\(self)"
        }
        return "\(self)"
    }
}
