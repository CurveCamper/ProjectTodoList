import Foundation

class FileCache: ObservableObject {

    @Published private(set) var todoItem : [TodoItem] = []

    func saveTasksToFile(named fileName: String, tasks: [TodoItem]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try JSONEncoder().encode(tasks)
            try data.write(to: fileURL)
        } catch {
            print("Не удалось сохранить данные: \(error.localizedDescription)")
        }
    }

    func loadTasksFromFile(named fileName: String) -> [TodoItem] {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fileURL)
            let tasks = try JSONDecoder().decode([TodoItem].self, from: data)
            return tasks
        } catch {
            print("Не удалось загрузить данные: \(error.localizedDescription)")
            return []
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}



