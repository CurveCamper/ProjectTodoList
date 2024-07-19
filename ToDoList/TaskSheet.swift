import SwiftUI

struct TaskSheet: View {
    @Binding var taskText: String
    @Binding var taskImportance: TodoItem.Importance
    @Binding var taskDeadline: Date
    @Binding var isDeadlineEnabled: Bool
    @Binding var taskColor: Color

    @State private var showCalendar: Bool = false
    @State private var showAlert: Bool = false
    @State private var brightness: Double = 1.0

    var isEditing: Bool
    var onSave: () -> Void
    var onCancel: () -> Void
    var onDelete: ((TodoItem) -> Void)?

    private var minimumDeadline: Date {
        Calendar.current.startOfDay(for: Date()).addingTimeInterval(24 * 60 * 60)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Section {
                        textEdit
                    }
                    
                    Section {
                        importance
                    }

                    Section {
                       colorPicker
                    }

                    Section {
                        toggle
                    }

                    Spacer()

                    if isEditing {
                        Button(action: {
                            if let onDelete = onDelete {
                                onDelete(TodoItem(text: taskText, importance: taskImportance, deadline: isDeadlineEnabled ? taskDeadline : nil, color: taskColor.toHex() ?? "#FFFFFF"))
                            }
                            onCancel()
                        }) {
                            Text("Удалить")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.backSecondary)
            .navigationTitle(isEditing ? "Редактировать задачу" : "Новая задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        if isDeadlineEnabled && taskDeadline < minimumDeadline {
                            showAlert = true
                        } else {
                            onSave()
                        }
                    }
                    .disabled(taskText.isEmpty)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Выберите валидную дату"),
                    message: Text("Дата выполнения должна быть не раньше, чем \(minimumDeadline, style: .date)."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .onChange(of: brightness) { newValue in
            taskColor = taskColor.adjustBrightness(by: newValue)
        }
    }
    
    
    private var textEdit: some View {
        TextEditor(text: $taskText)
            .frame(minHeight: 100)
            .cornerRadius(15)
            .padding()
            .background(Color(UIColor.white))
            .cornerRadius(10)
            .padding(.horizontal)
            .overlay(
                taskText.isEmpty ? Text("что нужно сделать?")
//                                    .padding(.top)
//                                    .padding(.leading) // не работает
                    .foregroundColor(.gray) : nil
            )
    }
    
    private var importance: some View {
        HStack {
            Text("Важность")
                .font(.headline)
            Spacer()
            Picker("Важность", selection: $taskImportance) {
                ForEach(TodoItem.Importance.allCases, id: \.self) { importance in
                    Text(importance.rawValue.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 150)
            .clipped()
        }
        .padding()
        .background(Color(UIColor.white))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var colorPicker: some View {
        VStack {
            Text("Выбранный цвет")
                .font(.headline)
                .padding(.bottom, 5)
            ColorPicker("Цвет задачи", selection: $taskColor)
                .padding(.horizontal)
            Slider(value: $brightness, in: 0...1, step: 0.1) {
                Text("Яркость")
            }
            .padding(.horizontal)
            Text(taskColor.toHex() ?? "#FFFFFF")
                .padding(.horizontal)
        }
        .padding()
        .background(Color(UIColor.white))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var toggle: some View {
        Toggle(isOn: Binding(
            get: { isDeadlineEnabled },
            set: { newValue in
                isDeadlineEnabled = newValue
                if newValue {
                    taskDeadline = minimumDeadline
                }
            })) {
            Text("Сделать до")
        }
        .padding()
        .background(Color(UIColor.white))
        .cornerRadius(10)
        .padding(.horizontal)

        if isDeadlineEnabled {
            Button(action: {
                withAnimation {
                    showCalendar.toggle()
                }
            }) {
                HStack {
                    Text("Дата выполнения")
                        .foregroundColor(Color.primary)
                    Spacer()
                    Text(taskDeadline, style: .date)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.white))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            if showCalendar {
                DatePicker(
                    "Дата выполнения",
                    selection: $taskDeadline,
                    in: minimumDeadline...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal)
                .transition(.move(edge: .leading))
                .animation(.default)
            }
        }
    }
}




