import SwiftUI

struct ContentView: View {
    @State private var tasks = [TodoItem]()
    @State private var showCompletedTask = false
    @State private var sortByImportance = false
    @State private var showFilters = false
    @State private var showTaskSheet = false
    @State private var editingTask: TodoItem?
    @State private var taskText = ""
    @State private var taskImportance: TodoItem.Importance = .normal
    @State private var taskDeadline: Date = Date()
    @State private var isDeadlineEnabled: Bool = false
    @State private var taskColor: Color = .white
    
    private var fileCache = FileCache()
    
    private let importanceOrder: [TodoItem.Importance: Int] = [
        .low: 1,
        .normal: 2,
        .high: 3
    ]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                content(geometry: geometry)
            }
        }
    }
    
    @ViewBuilder
    private func content(geometry: GeometryProxy) -> some View {
        ZStack {
            VStack(alignment: .leading) {
                FiltersView(
                    countingCompletedTasks: countingCompletedTasks,
                    showCompletedTask: $showCompletedTask,
                    sortByImportance: $sortByImportance
                )
                
                if geometry.size.width > geometry.size.height {
                    landscapeView()
                } else {
                    portraitView()
                }
            }
            AddTaskButton(showTaskSheet: $showTaskSheet, resetTaskFields: resetTaskFields)
                .sheet(isPresented: $showTaskSheet) {
                    TaskSheet(
                        taskText: $taskText,
                        taskImportance: $taskImportance,
                        taskDeadline: $taskDeadline,
                        isDeadlineEnabled: $isDeadlineEnabled,
                        taskColor: $taskColor,
                        isEditing: editingTask != nil,
                        onSave: {
                            if let task = editingTask {
                                updateTask(task)
                            } else {
                                addNewTask()
                            }
                            showTaskSheet = false
                        },
                        onCancel: {
                            showTaskSheet = false
                        },
                        onDelete: { task in
                            if let task = editingTask {
                                deleteTask(task: task)
                            }
                        }
                    )
                }
        }
    }
    
    private func landscapeView() -> some View {
        HStack {
            TaskListView(
                tasks: filteredTasks,
                onTaskTap: handleTaskTap,
                onTaskComplete: markAsCompleted,
                onTaskDelete: deleteTask
            )
            .onAppear {
                loadTasks()
            }
            
            Spacer()
            
            TaskDetailsView(taskText: $taskText)
        }
    }
    
    private func portraitView() -> some View {
        TaskListView(
            tasks: filteredTasks,
            onTaskTap: handleTaskTap,
            onTaskComplete: markAsCompleted,
            onTaskDelete: deleteTask
        )
        .onAppear {
            loadTasks()
        }
    }
    
    private func handleTaskTap(task: TodoItem) {
        editingTask = task
        taskText = task.text
        taskImportance = task.importance
        taskDeadline = task.deadline ?? Date()
        isDeadlineEnabled = task.deadline != nil
        taskColor = Color(hex: task.color) ?? .white
        showTaskSheet.toggle()
    }
    
    private var countingCompletedTasks: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    private var filteredTasks: [TodoItem] {
        var filtered = tasks.filter {
            !($0.isCompleted && !showCompletedTask)
        }
        if sortByImportance {
            filtered = filtered.sorted {
                importanceOrder[$0.importance]! > importanceOrder[$1.importance]!
            }
        }
        return filtered
    }
    
    private func markAsCompleted(task: TodoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            saveTasks()
        }
    }
    
    private func deleteTask(task: TodoItem) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    private func addNewTask() {
        let newTask = TodoItem(text: taskText, importance: taskImportance, deadLine: isDeadlineEnabled ? taskDeadline : nil, color: taskColor.toHex() ?? "#FFFFFF")
        tasks.append(newTask)
        saveTasks()
    }
    
    private func saveTasks() {
        fileCache.saveTasksToFile(named: "tasks.json", tasks: tasks)
    }
    
    private func loadTasks() {
        tasks = fileCache.loadTasksFromFile(named: "tasks.json")
    }
    
    private func updateTask(_ task: TodoItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].text = taskText
            tasks[index].importance = taskImportance
            tasks[index].deadline = isDeadlineEnabled ? taskDeadline : nil
            tasks[index].color = taskColor.toHex() ?? "#FFFFFF"
            saveTasks()
        }
    }
    
    private func resetTaskFields() {
        editingTask = nil
        taskText = ""
        taskImportance = .normal
        taskDeadline = Date()
        isDeadlineEnabled = false
        taskColor = .white
    }
}




extension Color {
    func toHex() -> String? {
        let components = UIColor(self).cgColor.components
        let r = Float(components?[0] ?? 0)
        let g = Float(components?[1] ?? 0)
        let b = Float(components?[2] ?? 0)
        return String(format: "#%02lX%02lX%02lX", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    func adjustBrightness(by value: Double) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Color(red: Double(red) * value, green: Double(green) * value, blue: Double(blue) * value, opacity: Double(alpha))
    }
    init?(hex: String) {
        let r, g, b, a: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, opacity: a)
                    return
                }
            }
        }
        return nil
    }
}

