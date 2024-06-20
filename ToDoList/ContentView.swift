//
//  ContentView.swift
//  ToDoList
//
//  Created by Viktor on 17.06.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            Text("Hello, world!")
    }
}





struct TodoItem: Identifiable { // сейчас вроде не нужен Identifiable, но при работе с ui вроде как нужен будет
    
    let id: String // уникальный идентиаифкатор id
    
    let text : String // строковое поле text
    
    let importance: Importance // поле важности записи
    
    let isCompleted: Bool // флаг сделана или нет (для тогла)
    
    let deadLine: Date? // дедлайн если есть
    
    let creationDate: Date // дата создания
    
    let modificationDate: Date? // дата изменения если будет
    
    enum Importance : String, Codable {
        case low = "Неважная"
        case normal = "Обычная"
        case high = "Важная"
    }
    
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, isCompleted: Bool = false, deadLine: Date? = nil, creationDate: Date = Date(), modificationDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.isCompleted = isCompleted
        self.deadLine = deadLine
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}





class FileCache {
    
    private var todoItem : [TodoItem] = [] // возможно private(set) смотря на сколько и где открытую для получения
    
    
    func addNewTask(_ item: TodoItem) {
        
        // проверим на наличие записи с таким же id, можно как генерить новый id записи или просто выводить ошибку об сущетсовании записи
        if todoItem.contains(where: {$0.id == item.id}) {
            // здесь код который нужен будет по заданию для обработки такой записи
            return
        }
        
        // добавляем если это новая запись
        todoItem.append(item)
    }
    
    
    func removeTask(_ id: String) {
        //возможно функция должна выглядеть подругому в дальнейшем
        if let index = todoItem.firstIndex(where: {$0.id == id}) {
            todoItem.remove(at: index)
        }
        
    }
    
    
    // не уверен за работоспособность загрузки и сохранения, вероятно в дальнейшем нужно переписать/дописать эти функции
    func saveTaskToFile(named fileName: String) {
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let data = try! JSONSerialization.data(withJSONObject: todoItem.map({$0.json}), options: [])
        try! data.write(to: fileURL)
        
    }
    
    func loadTaskFromFile(named fileName: String) {
        
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let data = try! Data(contentsOf: fileURL)
        if let jsonArray = try! JSONSerialization.jsonObject(with: data, options: []) as? [Any] {
            todoItem = jsonArray.compactMap { TodoItem.parse(json: $0) }
        }
        
    }
    
    // функция поиска пути к файлу
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        print("Documents Directory: \(documentsDirectory.path)") // для отображения пути к файлу json
        return documentsDirectory
    }
    
}





extension TodoItem {
    
    // разбор JSON
    static func parse(json: Any) -> TodoItem? {
        
        // проверка может ли быть представлен как словарь
        guard let jsonDict = json as? [String: Any] else {
            return nil
        }
        
        // проверка на возможность взять ключевые данные в тех типах значений которые нам нужны
        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let isCompleted = jsonDict["isCompleted"] as? Bool,
              let creationDateString = jsonDict["creationDate"] as? String,
              let creationDate = ISO8601DateFormatter().date(from: creationDateString) else {
            return nil
        }
        
        // проверка на важность записи, если такое не получится то присваиваем ей нормальную важность
        let importanceString = jsonDict["importance"] as? String
        let importance = Importance(rawValue: importanceString ?? "Обычная") ?? .normal
        
        // пытаемся взять дату модификации если она есть как строку, тк jsonDict["modificationDate"] - имеет тип "any?"
        let modificationDateString = jsonDict["modificationDate"] as? String // - nil or String?
        let modificationDate = modificationDateString != nil ? ISO8601DateFormatter().date(from: modificationDateString!) : nil
        
        // пытаемся взять дату дедлайна если она есть, тоже самое что и с датой модификации
        let deadLineString = jsonDict["deadLine"] as? String
        let deadLine = deadLineString != nil ? ISO8601DateFormatter().date(from: deadLineString!) : nil
        
        // создание нового обьекта
        return TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, deadLine: deadLine, creationDate: creationDate, modificationDate: modificationDate)
    }
    
    // формирование JSON
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
        
        if let modificationDate = modificationDate {
            jsonDict["modificationDate"] = ISO8601DateFormatter().string(from: modificationDate)
        }
        
        if let deadLine = deadLine {
            jsonDict["deadLine"] = ISO8601DateFormatter().string(from: deadLine)
        }
        
        return jsonDict
    }
    
    
    // Преобразование в CSV строку
        func toCSV() -> String {
            
            // приводим даты если они есть к стрингам через iso8601datedormatter, если нет то просто пустая строка
            let dateFormatter = ISO8601DateFormatter()
            let deadLineString = deadLine != nil ? dateFormatter.string(from: deadLine!) : ""
            let modificationDateString = modificationDate != nil ? dateFormatter.string(from: modificationDate!) : ""
            let creationDateString = dateFormatter.string(from: creationDate)
            
            return "\(id),\(text),\(importance.rawValue),\(isCompleted),\(deadLineString),\(creationDateString),\(modificationDateString)"
        }
        
        // Инициализация из CSV строки
        static func fromCSV(_ csv: String) -> TodoItem? {
            
            // разделяем строку и преобразуем в строку
            let components = csv.split(separator: ",").map { String($0) }
            
            let dateFormatter = ISO8601DateFormatter()
            
            // инициализируем поля
            let id = components[0]
            let text = components[1]
            let importance = Importance(rawValue: components[2]) ?? .normal
            let isCompleted = Bool(components[3]) ?? false
            let deadLine = components[4].isEmpty ? nil : dateFormatter.date(from: components[4])
            guard let creationDate = dateFormatter.date(from: components[5]) else { return nil } // гуард используем изза того что это обязательное поле котроое может не поддаться форматированию
            let modificationDate = components.count > 6 && !components[6].isEmpty ? dateFormatter.date(from: components[6]) : nil
            
            return TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, deadLine: deadLine, creationDate: creationDate, modificationDate: modificationDate)
        }
}
