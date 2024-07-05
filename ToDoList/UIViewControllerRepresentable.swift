import SwiftUI
import UIKit

struct ToDoListViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var tasks: [TodoItem]

    func makeUIViewController(context: Context) -> ToDoListViewController {
        let viewController = ToDoListViewController()
        viewController.tasks = tasks
        return viewController
    }

    func updateUIViewController(_ uiViewController: ToDoListViewController, context: Context) {
        uiViewController.tasks = tasks
        uiViewController.reloadTableViewData()
    }
}


