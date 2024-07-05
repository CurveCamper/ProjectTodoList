import SwiftUI

struct TaskListView: View {
    let tasks: [TodoItem]
    let onTaskTap: (TodoItem) -> Void
    let onTaskComplete: (TodoItem) -> Void
    let onTaskDelete: (TodoItem) -> Void
    
    var body: some View {
        List(tasks) { task in
            HStack {
                taskContent(task)
                Spacer()
                Color(hex: task.color)?
                    .frame(width: 5)
                    .cornerRadius(2.5)
                Image(systemName: "chevron.right")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTaskTap(task)
            }
            .swipeActions(edge: .leading) {
                Button {
                    onTaskComplete(task)
                } label: {
                    Label("Выполнено", systemImage: "checkmark.circle")
                }
                .tint(.green)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    onTaskDelete(task)
                } label: {
                    Label("Удалить", systemImage: "trash")
                }
            }
        }
    }
    
    @ViewBuilder
    private func taskContent(_ task: TodoItem) -> some View {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
            .foregroundColor(task.isCompleted ? .green : (task.importance == .high ? .red : .gray))
        VStack(alignment: .leading) {
            Text(task.text)
                .strikethrough(task.isCompleted)
                .lineLimit(1)
            if let deadline = task.deadline {
                Text(deadline, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}




struct TaskDetailsView: View {
    @Binding var taskText: String
    
    var body: some View {
        VStack {
            TextEditor(text: $taskText)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
        }
        .padding()
    }
}

