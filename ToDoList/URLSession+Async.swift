import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) throws -> (Data, URLResponse) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: (data: Data?, response: URLResponse?, error: Error?)?
        
        let task = self.dataTask(with: urlRequest) { data, response, error in
            result = (data: data, response: response, error: error)
            semaphore.signal()
        }
        
        let workItem = DispatchWorkItem {
            task.resume()
        }
        
        DispatchQueue.global().async(execute: workItem)
        
        defer {
            workItem.cancel()
            task.cancel()
        }
        
        semaphore.wait()
        
        if let error = result?.error {
            throw error
        }
        
        guard let data = result?.data, let response = result?.response else {
            throw URLError(.badServerResponse)
        }
        
        return (data, response)
    }
}
