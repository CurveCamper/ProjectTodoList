import SwiftUI

struct FiltersView: View {
    let countingCompletedTasks: Int
    @Binding var showCompletedTask: Bool
    @Binding var sortByImportance: Bool

    var body: some View {
        HStack {
            Text("Выполнено - \(countingCompletedTasks)")
                .font(.system(size: 14))
                .padding(.leading)
                .foregroundColor(.gray)

            Spacer()

            Menu {
                Section {
                    Button(action: {
                        showCompletedTask.toggle()
                    }) {
                        Text(showCompletedTask ? "Скрыть выполненные" : "Показать выполненные")
                    }
                }

                Section {
                    Button(action: {
                        sortByImportance.toggle()
                    }) {
                        Text(sortByImportance ? "Сортировать по добавлению" : "Сортировать по важности")
                    }
                }
            } label: {
                Text("Фильтры")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
            .padding(.trailing)
        }
        .padding(.top)
    }
}

