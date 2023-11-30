//
//  TaskViewController.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import UIKit
import RealmSwift

final class TaskViewController: UIViewController {
    
    var taskList: TaskList!
    
    private var storageManager = StorageManager.shared
    
    private var currentTasks: Results<Task> {
        taskList.tasks.filter("\(TaskKeys.isComplete.rawValue) = false")
    }
    
    private var completedTasks: Results<Task> {
        taskList.tasks.filter("\(TaskKeys.isComplete.rawValue) = true")
    }
    
    // MARK: UI
    private lazy var tableView: UITableView = {
        let tableView = TableViewBuilder(cellID: ViewControllers.taskVC.cellID, self: self)
        return tableView.build()
    }()
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
}

// MARK: Methods
private extension TaskViewController {
    
    func fetchData() {
//        storageManager.fetchData(type: [TaskList].self) { taskLists in
//            self.activityIndicator.stopAnimating()
//            
//            var index = 0
//            var delay = 0.0
//            
//            taskLists.forEach { taskList in
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                    self.taskLists.append(taskList)
//                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//                    index += 1
//                }
//                delay += 0.35
//            }
//            
//        }
    }
    
    @objc func buttonAddPressed() { showAlert() }
    
    @objc func buttonTrashPressed() {
        let alert = AlertControllerBuilder(title: "Clear all Tasks?", message: nil)
        alert.addActionCancel()
        alert.addAction(title: "Proceed", style: .default) {
            self.storageManager.clearTasks(for: self.taskList) {
                self.tableView.reloadData()
            }
        }
        present(alert.build(), animated: true)
    }
    
    func save(title: String?, description: String?) {
        guard let title, !title.isEmpty else {
            showAlertError(title: "Title can't be empty")
            return
        }
        
        let task = Task()
        task.title = title
        task.note = description ?? ""
        
        storageManager.save(task: task, to: taskList) {
            self.tableView.insertRows(at: [IndexPath(row: self.currentTasks.index(of: task) ?? 0, section: 0)], with: .automatic)
        }
    }
    
    // TODO: Implement
    func edit(_ task: Task, title: String?, description: String?) {
        guard let title, !title.isEmpty else {
            showAlertError(title: "Title can't be empty")
            return
        }
        
        storageManager.edit(taskList: taskList, for: task, with: title, and: description)
    }
    
}

// MARK: UI Methods
private extension TaskViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        title = taskList.title
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonAddPressed)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(buttonTrashPressed))
//            editButtonItem
        ]
        
        
        setupSubviews(tableView)
        setupConstraints()
    }
    
    func setupSubviews(_ views: UIView...) {
        views.forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
}

private extension TaskViewController {
    
    private func showAlertError(title: String) {
        let alert = AlertControllerBuilder(title: title, message: nil)
            .addAction(title: "OK", style: .cancel, handler: nil)
        present(alert.build(), animated: true)
        return
    }
    
    private func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let alert = AlertControllerBuilder(
            title: "\(task == nil ? "New" : "Edit") Task",
            message: "\(task == nil ? "Add" : "Edit") description (optional)"
        )
        
        alert
            .addTextField(placeholder: "Task Title", text: task == nil ? nil : "\(task?.title ?? "")")
            .addTextField(placeholder: "Task Description", text: task == nil ? nil : "\(task?.note ?? "")")
            .addActionCancel()
            .addAction(title: task == nil ? "Save" : "Save Shanges", style: .default) { [unowned self] in
                if let task {
                    edit(task, title: alert.firstTextFieldText(), description: alert.lastTextFieldText())
                    completion?()
                } else {
                    save(title: alert.firstTextFieldText(), description: alert.lastTextFieldText())
                }
            }
        
        present(alert.build(), animated: true)
    }
    
}

// MARK: Protocols. UITableView...
extension TaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: TODO
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllers.taskVC.cellID, for: indexPath)
        
        let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        content.secondaryText = task.note
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let isComplete = (indexPath.section == 1)
        let task = isComplete ? completedTasks[indexPath.row] : currentTasks[indexPath.row]
        
        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.storageManager.delete(taskList: self.taskList, for: task) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        let actionEdit = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(with: task) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let actionDone = UIContextualAction(style: .normal, title: isComplete ? "Undone" : "Done") { _, _, isDone in
            if isComplete {
                self.storageManager.undone(taskList: self.taskList, for: task) {
                    tableView.moveRow(at: indexPath, to: IndexPath(row: self.currentTasks.index(of: task) ?? 0, section: 0))
                }
            } else {
                self.storageManager.done(taskList: self.taskList, for: task) {
                    tableView.moveRow(at: indexPath, to: IndexPath(row: self.completedTasks.index(of: task) ?? 0, section: 1))
                }
            }
            
        }
        
        actionEdit.backgroundColor = .orange
        actionDone.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [actionDone, actionEdit, actionDelete])
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
