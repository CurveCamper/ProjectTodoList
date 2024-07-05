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
                    .navigationBarTitle("Мои дела", displayMode: .inline)
                    .navigationBarItems(trailing: calendarNavigationLink)
            }
        }
    }

    private var calendarNavigationLink: some View {
        HStack {
            Spacer()
            NavigationLink(destination: ToDoListViewControllerRepresentable(tasks: $tasks)) {
                Image(systemName: "calendar")
                    .resizable()
                    .frame(width: 30, height: 30)
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

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
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

#Preview {
    ContentView()
}
