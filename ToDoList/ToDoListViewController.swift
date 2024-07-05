import UIKit
import SwiftUI

class ToDoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let addButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "plus"), for: .normal)
            button.tintColor = .white
            button.backgroundColor = .blue
            button.layer.cornerRadius = 30
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.7
            button.layer.shadowRadius = 2
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()

        private func setupAddButtonConstraints() {
            NSLayoutConstraint.activate([
                addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -165),
                addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15),
                addButton.widthAnchor.constraint(equalToConstant: 60),
                addButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        @objc private func addButtonTapped() {
            
            let taskSheet = TaskSheet(
                taskText: .constant(""),
                taskImportance: .constant(.normal),
                taskDeadline: .constant(Date()),
                isDeadlineEnabled: .constant(false),
                taskColor: .constant(.white),
                isEditing: false,
                onSave: {  },
                onCancel: { self.dismiss(animated: true, completion: nil) },
                onDelete: { _ in }
            )
            let hostingController = UIHostingController(rootView: taskSheet)
            present(hostingController, animated: true, completion: nil)
        }
    
    var tasks: [TodoItem] = []
    private var tableView: UITableView!
    private var collectionView: UICollectionView!
    private var separatorLine: UIView!
    private var dateKeys: [Date] = []
    private var selectedIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Получение уникальных дат задач и их сортировка
        dateKeys = Array(Set(tasks.compactMap { $0.deadline })).sorted()

        // Настройка коллекции
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "DateCell")
        view.addSubview(collectionView)

        // Настройка линии разделения
        separatorLine = UIView()
        separatorLine.backgroundColor = .gray
        view.addSubview(separatorLine)

        // Настройка таблицы
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        // Регистрация ячеек
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")

        // Настройка ограничений Auto Layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 50),

            separatorLine.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),

            tableView.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(addButton)
        setupAddButtonConstraints()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
    }

    func reloadTableViewData() {
        dateKeys = Array(Set(tasks.compactMap { $0.deadline })).sorted()
        tableView.reloadData()
        collectionView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return dateKeys.count + 1 // Плюс одна секция для "Другое"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < dateKeys.count {
            let key = dateKeys[section]
            return tasks.filter { $0.deadline == key }.count
        } else {
            // Секция "Другое"
            return tasks.filter { $0.deadline == nil }.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)

        let task: TodoItem
        if indexPath.section < dateKeys.count {
            let key = dateKeys[indexPath.section]
            let tasksForKey = tasks.filter { $0.deadline == key }
            task = tasksForKey[indexPath.row]
        } else {
            let tasksWithoutDate = tasks.filter { $0.deadline == nil }
            task = tasksWithoutDate[indexPath.row]
        }

        let text = task.text
        let attributeString = NSMutableAttributedString(string: text)

        if task.isCompleted {
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
            cell.textLabel?.textColor = .gray
        } else {
            cell.textLabel?.textColor = .black
        }

        cell.textLabel?.attributedText = attributeString

        // Применение скругления к ячейке
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.borderWidth = 0.5
        cell.contentView.layer.borderColor = UIColor.lightGray.cgColor

        return cell
    }
    

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < dateKeys.count {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: dateKeys[section])
        } else {
            return "Другое"
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task: TodoItem
        if indexPath.section < dateKeys.count {
            let key = dateKeys[indexPath.section]
            let tasksForKey = tasks.filter { $0.deadline == key }
            task = tasksForKey[indexPath.row]
        } else {
            let tasksWithoutDate = tasks.filter { $0.deadline == nil }
            task = tasksWithoutDate[indexPath.row]
        }

        let taskSheet = TaskSheet(
            taskText: .constant(task.text),
            taskImportance: .constant(task.importance),
            taskDeadline: .constant(task.deadline ?? Date()),
            isDeadlineEnabled: .constant(task.deadline != nil),
            taskColor: .constant(Color(hex: task.color) ?? .white),
            isEditing: true,
            onSave: {
                // Логика сохранения изменений
            },
            onCancel: {
                self.dismiss(animated: true, completion: nil)
            },
            onDelete: { todoItem in
                // Логика удаления задачи
            }
        )
        


        let hostingController = UIHostingController(rootView: taskSheet)
        present(hostingController, animated: true, completion: nil)
    }

    // Добавление действий свайпа
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = UIContextualAction(style: .normal, title: "Выполнено") { (action, view, completionHandler) in
            self.updateTaskCompletion(at: indexPath, isCompleted: true)
            completionHandler(true)
        }
        completeAction.backgroundColor = .green

        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let incompleteAction = UIContextualAction(style: .normal, title: "Не выполнено") { (action, view, completionHandler) in
            self.updateTaskCompletion(at: indexPath, isCompleted: false)
            completionHandler(true)
        }
        incompleteAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [incompleteAction])
    }

    private func updateTaskCompletion(at indexPath: IndexPath, isCompleted: Bool) {
        let task: TodoItem
        if indexPath.section < dateKeys.count {
            let key = dateKeys[indexPath.section]
            var tasksForKey = tasks.filter { $0.deadline == key }
            task = tasksForKey[indexPath.row]
            if let index = tasks.firstIndex(of: task) {
                tasks[index].isCompleted = isCompleted
            }
        } else {
            var tasksWithoutDate = tasks.filter { $0.deadline == nil }
            task = tasksWithoutDate[indexPath.row]
            if let index = tasks.firstIndex(of: task) {
                tasks[index].isCompleted = isCompleted
            }
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath)

        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }

        let label = UILabel(frame: cell.bounds)
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        label.text = formatter.string(from: dateKeys[indexPath.item])
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        cell.contentView.addSubview(label)

        if selectedIndexPath == indexPath {
            cell.backgroundColor = .darkGray
            label.textColor = .white
        } else {
            cell.backgroundColor = .lightGray
            label.textColor = .black
        }

        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        collectionView.reloadData()

        // Определяем правильный индекс секции
        let section = indexPath.item
        let indexPath = IndexPath(row: 0, section: section)

        // Скроллим таблицу к выбранной секции
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}



