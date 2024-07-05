import Foundation
import Combine
import UIKit

class TaskStore: ObservableObject {
    @Published var tasks: [TodoItem] = []
}

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
            deadLine: Date? = nil,
            creationDate: Date = .now,
            modificationDate: Date? = nil,
            color: String = "#FFFFFF"
        ) {
            self.id = id
            self.text = text
            self.importance = importance
            self.isCompleted = isCompleted
            //self.deadline = deadline
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.color = color
        }
}



extension TodoItem {
    

    static func parse(json: Any) -> TodoItem? {
        
        guard let jsonDict = json as? [String: Any] else {
            return nil
        }
        
        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isCompleted = jsonDict["isCompleted"] as? Bool,
              let creationDateString = jsonDict["creationDate"] as? String,
              let creationDate = ISO8601DateFormatter().date(from: creationDateString) else {
            return nil
        }
        
        let importanceString = jsonDict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? "Обычная") ?? .normal
        
        let modificationDateString = jsonDict["modificationDate"] as? String
        let modificationDate = modificationDateString != nil ? ISO8601DateFormatter().date(from: modificationDateString!) : nil
        
        let deadLineString = jsonDict["deadLine"] as? String
        let deadLine = deadLineString != nil ? ISO8601DateFormatter().date(from: deadLineString!) : nil
        
        return TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, deadLine: deadLine, creationDate: creationDate, modificationDate: modificationDate)
    }
    
    
    var json: Any {
        var jsonDict: [String: Any] = [
            "id": id,
            "text": text,
            "isCompleted": isCompleted,
            "creationDate": ISO8601DateFormatter().string(from: creationDate)
        ]
        
        if importance != .normal {
            jsonDict["importance"] = importance.rawValue
        }
        
        if let modificationDate {
            jsonDict["modificationDate"] = ISO8601DateFormatter().string(from: modificationDate)
        }
        
        if let deadline {
            jsonDict["deadLine"] = ISO8601DateFormatter().string(from: deadline)
        }
        
        return jsonDict
    }
    
    
    func toCSV() -> String {
        let dateFormatter = ISO8601DateFormatter()
        
        var csvValues: [String] = []
        csvValues.append(id)
        csvValues.append(text)
        csvValues.append(importance.rawValue)
        csvValues.append(String(isCompleted))
        csvValues.append(deadline != nil ? dateFormatter.string(from: deadline!) : "")
        csvValues.append(dateFormatter.string(from: creationDate))
        csvValues.append(modificationDate != nil ? dateFormatter.string(from: modificationDate!) : "")
        
        return csvValues.joined(separator: ",")
    }

    
    static func fromCSV(_ csv: String) -> TodoItem? {
        
        let components = csv.split(separator: ",").map { String($0) }
        
        let dateFormatter = ISO8601DateFormatter()
        
        let id = components[0]
        let text = components[1]
        let importance = Importance(rawValue: components[2]) ?? .normal
        let isCompleted = Bool(components[3]) ?? false
        let deadline = components[4].isEmpty ? nil : dateFormatter.date(from: components[4])
        guard let creationDate = dateFormatter.date(from: components[5]) else { return nil }
        let modificationDate = components.count > 6 && !components[6].isEmpty ? dateFormatter.date(from: components[6]) : nil
        
        return TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, deadLine: deadline, creationDate: creationDate, modificationDate: modificationDate)
    }
}

