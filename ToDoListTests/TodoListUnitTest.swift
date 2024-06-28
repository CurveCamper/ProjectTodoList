//
//  TodoListUnitTest.swift
//  ToDoListTests
//
//  Created by Viktor on 19.06.2024.
//
//import XCTest
//@testable import ToDoList
//
//class TodoItemTests: XCTestCase {
//
//    func testInitialization() {
//        let id = "1"
//        let text = "Тестовая задача"
//        let importance = TodoItem.Importance.high
//        let isCompleted = false
//        let creationDate = Date()
//        let deadLine = Date()
//
//        let item = TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, creationDate: creationDate)
//
//        XCTAssertEqual(item.id, id)
//        XCTAssertEqual(item.text, text)
//        XCTAssertEqual(item.importance, importance)
//        XCTAssertEqual(item.isCompleted, isCompleted)
//        XCTAssertEqual(item.creationDate, creationDate)
//        XCTAssertNil(item.deadLine)
//        XCTAssertNil(item.modificationDate)
//    }
//
//    func testJSONSerialization() {
//        let id = "1"
//        let text = "Тестовая задача"
//        let importance = TodoItem.Importance.high
//        let isCompleted = false
//        let creationDate = Date()
//        let modificationDate = Date(timeIntervalSince1970: 1624080600)
//
//        let item = TodoItem(id: id, text: text, importance: importance, isCompleted: isCompleted, creationDate: creationDate, modificationDate: modificationDate)
//
//        let json = item.json as? [String: Any]
//        XCTAssertNotNil(json)
//
//        XCTAssertEqual(json?["id"] as? String, id)
//        XCTAssertEqual(json?["text"] as? String, text)
//        XCTAssertEqual(json?["importance"] as? String, importance.rawValue)
//        XCTAssertEqual(json?["isCompleted"] as? Bool, isCompleted)
//        XCTAssertEqual(json?["creationDate"] as? String, ISO8601DateFormatter().string(from: creationDate))
//        XCTAssertEqual(json?["modificationDate"] as? String, ISO8601DateFormatter().string(from: modificationDate))
//    }
//
//    func testJSONParsing() {
//        let json: [String: Any] = [
//            "id": "1",
//            "text": "Тестовая задача",
//            "importance": "Важная",
//            "isCompleted": false,
//            "creationDate": "2024-06-19T12:00:00Z"
//        ]
//
//        let item = TodoItem.parse(json: json)
//        XCTAssertNotNil(item)
//
//        XCTAssertEqual(item?.id, "1")
//        XCTAssertEqual(item?.text, "Тестовая задача")
//        XCTAssertEqual(item?.importance, .high)
//        XCTAssertEqual(item?.isCompleted, false)
//
//        let expectedDate = ISO8601DateFormatter().date(from: "2024-06-19T12:00:00Z")
//        XCTAssertEqual(item?.creationDate, expectedDate)
//    }
//
//}
