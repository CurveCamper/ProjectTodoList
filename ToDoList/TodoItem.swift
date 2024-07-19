import Foundation
import UIKit
import Combine

struct TodoItem: Identifiable, Codable, Equatable {
    let id: String
    var text: String
    var importance: Importance
    var isCompleted: Bool = false
    let creationDate: Date
    let modificationDate: Date?
    var deadline: Date?
    var color: String = "#FFFFFF"
    
    enum Importance: String, CaseIterable, Codable {
        case low, normal, high
    }
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        isCompleted: Bool = false,
        deadline: Date? = nil,
        creationDate: Date = .now,
        modificationDate: Date? = nil,
        color: String = "#FFFFFF"
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isCompleted = isCompleted
        self.deadline = deadline
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.color = color
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let jsonDict = json as? [String: Any] else {
            print("Failed to cast json as [String: Any]")
            return nil
        }
        
        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isCompleted = jsonDict["isCompleted"] as? Bool,
              let creationDateString = jsonDict["creationDate"] as? String,
              let creationDate = ISO8601DateFormatter().date(from: creationDateString) else {
            print("Failed to parse required fields from json")
            return nil
        }
        
        let importanceString = jsonDict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? "normal") ?? .normal
        
        let modificationDateString = jsonDict["modificationDate"] as? String
        let modificationDate = modificationDateString != nil ? ISO8601DateFormatter().date(from: modificationDateString!) : nil
        
        let deadlineString = jsonDict["deadline"] as? String
        let deadline = deadlineString != nil ? ISO8601DateFormatter().date(from: deadlineString!) : nil
        
        return TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, deadline: deadline, creationDate: creationDate, modificationDate: modificationDate)
    }
    
    var json: Any {
        var jsonDict: [String: Any] = [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "isCompleted": isCompleted,
            "creationDate": ISO8601DateFormatter().string(from: creationDate)
        ]
        
        if let modificationDate = modificationDate {
            jsonDict["modificationDate"] = ISO8601DateFormatter().string(from: modificationDate)
        }
        
        if let deadline = deadline {
            jsonDict["deadline"] = ISO8601DateFormatter().string(from: deadline)
        }
        
        jsonDict["color"] = color
        
        return jsonDict
    }
}
