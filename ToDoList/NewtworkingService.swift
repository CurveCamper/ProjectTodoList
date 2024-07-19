import Foundation
import CocoaLumberjackSwift
import Combine

class NetworkingService {
    static let shared = NetworkingService()
    private let baseURL = "https://hive.mrdekk.ru/todo"
    private let token = "Aranwe"
    
    private var headers: [String: String] {
        return ["Authorization": "Bearer \(token)", "Content-Type": "application/json"]
    }
    
    func fetchTasks(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list") else { return }
        
        performRequest(url: url, method: "GET", completion: { (result: Result<TodoResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.list))
                for task in response.list {
                    DDLogInfo("Task JSON: \(task.json)")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func addTask(_ task: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = try JSONEncoder().encode(task)
            
            logRequest(request)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DDLogError("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "No data", code: 0, userInfo: nil)
                    DDLogError("Error: No data received")
                    completion(.failure(error))
                    return
                }
                
                self.logResponse(response, data: data)
                
                do {
                    let result = try JSONDecoder().decode(TodoItem.self, from: data)
                    completion(.success(result))
                } catch {
                    DDLogError("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            DDLogError("Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func updateTaskList(_ tasks: [TodoItem], revision: Int, completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PATCH"
            request.allHTTPHeaderFields = headers
            request.addValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
            request.httpBody = try JSONEncoder().encode(tasks)
            
            logRequest(request)
            
            performRequest(url: url, method: "PATCH", completion: { (result: Result<TodoResponse, Error>) in
                switch result {
                case .success(let response):
                    completion(.success(response.list))
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } catch {
            DDLogError("Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func updateTask(_ task: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list/\(task.id)") else { return }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = try JSONEncoder().encode(task)
            
            logRequest(request)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DDLogError("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "No data", code: 0, userInfo: nil)
                    DDLogError("Error: No data received")
                    completion(.failure(error))
                    return
                }
                
                self.logResponse(response, data: data)
                
                do {
                    let result = try JSONDecoder().decode(TodoItem.self, from: data)
                    completion(.success(result))
                } catch {
                    DDLogError("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            DDLogError("Error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func deleteTask(_ taskID: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/list/\(taskID)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = headers
        
        logRequest(request)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DDLogError("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No data", code: 0, userInfo: nil)
                DDLogError("Error: No data received")
                completion(.failure(error))
                return
            }
            
            self.logResponse(response, data: data)
            
            do {
                let result = try JSONDecoder().decode(TodoItem.self, from: data)
                completion(.success(result))
            } catch {
                DDLogError("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func performRequest<T: Decodable>(url: URL, method: String, completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        logRequest(request)
        
        let maxRetries = 5
        var currentRetry = 0
        
        func executeRequest() {
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    if currentRetry < maxRetries {
                        currentRetry += 1
                        let delay = pow(2.0, Double(currentRetry))
                        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                            executeRequest()
                        }
                    } else {
                        DDLogError("Error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "No data", code: 0, userInfo: nil)
                    DDLogError("Error: No data received")
                    completion(.failure(error))
                    return
                }
                
                self.logResponse(response, data: data)
                
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(result))
                } catch {
                    DDLogError("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }.resume()
        }
        
        executeRequest()
    }
    
    private func logRequest(_ request: URLRequest) {
        if let method = request.httpMethod, let url = request.url {
            DDLogInfo("Request: \(method) \(url)")
        }
        if let headers = request.allHTTPHeaderFields {
            DDLogInfo("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            DDLogInfo("Body: \(bodyString)")
        }
    }
    
    private func logResponse(_ response: URLResponse?, data: Data) {
        if let httpResponse = response as? HTTPURLResponse {
            DDLogInfo("Response: \(httpResponse.statusCode)")
        }
        let responseString = String(data: data, encoding: .utf8) ?? "No response body"
        DDLogInfo("Response Body: \(responseString)")
    }
}

struct TodoResponse: Codable {
    let status: String
    let list: [TodoItem]
    let revision: Int
}

class TaskStore: ObservableObject {
    @Published var tasks: [TodoItem] = []
    private var cancellables = Set<AnyCancellable>()
    private var isDirty: Bool = false
    
    init() {
        loadLocalTasks()
        syncIfDirty()
    }
    
    private func loadLocalTasks() {
        // Загрузка задач из локального хранилища
    }
    
    private func saveLocalTasks() {
        // Сохранение задач в локальное хранилище
    }
    
    private func markAsDirty() {
        isDirty = true
        saveLocalTasks()
        syncIfDirty()
    }
    
    func addTask(_ task: TodoItem) {
        tasks.append(task)
        markAsDirty()
    }
    
    func updateTask(_ task: TodoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            markAsDirty()
        }
    }
    
    func deleteTask(_ task: TodoItem) {
        tasks.removeAll { $0.id == task.id }
        markAsDirty()
    }
    
    private func syncIfDirty() {
        guard isDirty else { return }
        
        NetworkingService.shared.updateTaskList(tasks, revision: 1) { result in
            switch result {
            case .success(let tasks):
                self.tasks = tasks
                self.isDirty = false
                self.saveLocalTasks()
            case .failure(let error):
                DDLogError("Error syncing tasks: \(error.localizedDescription)")
            }
        }
    }
}
