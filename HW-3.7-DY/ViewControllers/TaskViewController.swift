//
//  TaskViewController.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import UIKit

final class TaskViewController: UIViewController {
    
    var taskList: TaskList!
    
    private var storageManager = StorageManager.shared
    
    private var currentTasks: [Task] {
        var tasks = [Task]()
        taskList.tasks.forEach { if !$0.isComplete { tasks.append($0) } }
        return tasks
    }
    
    private var completedTasks: [Task] {
        var tasks = [Task]()
        taskList.tasks.forEach { if $0.isComplete { tasks.append($0) } }
        return tasks
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
    
    func save(title: String?, description: String?) {
        guard let title, !title.isEmpty else {
            let alert = AlertControllerBuilder(title: "Title can't be empty", message: nil)
                .addAction(title: "OK", style: .cancel, handler: nil)
            present(alert.build(), animated: true)
            return
        }
//        let task = Task(title: title, note: description)
        
        self.taskList.tasks.forEach( { print("TaskList0: \($0.title)") } )
//        storageManager.save(task: task, to: taskList) {
//            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        }
    }
    
    // TODO: Implement
    func edit(_ task: Task) {}
    
}

// MARK: UI Methods
private extension TaskViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        title = taskList.title
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonAddPressed)),
            editButtonItem
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
    
    private func showAlert(with task: Task? = nil) {
        let alert = AlertControllerBuilder(
            title: "\(task == nil ? "New" : "Edit") Task",
            message: "Add description (optional)"
        )
        
        alert
            .addTextField(placeholder: "Task Title", text: nil)
            .addTextField(placeholder: "Task Description", text: nil)
            .addActionCancel()
            .addAction(title: task == nil ? "Save" : "Save Shanges", style: .default) { [unowned self] in
                task == nil ? save(title: alert.firstTextFieldText(), description: alert.lastTextFieldText()) : edit(task!)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
