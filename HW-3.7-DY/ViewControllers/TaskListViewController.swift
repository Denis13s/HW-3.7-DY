//
//  TaskListViewController.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import UIKit

final class TaskListViewController: UIViewController {
    
    // MARK: Properties
    private var storageManager = StorageManager.shared
    private var taskLists: [TaskList] = []
    
    // MARK: UI
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Data", at: 0, animated: false)
        control.insertSegment(withTitle: "A-Z", at: 1, animated: false)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = TableViewBuilder(cellID: ViewControllers.taskListVC.cellID, self: self)
        return tableView.build()
    }()
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
}

// MARK: Private Methods
private extension TaskListViewController {
    
    func fetchData() {
        storageManager.fetchData(type: [TaskList].self) { taskLists in
            self.activityIndicator.stopAnimating()
            
            var index = 0
            var delay = 0.0
            
            taskLists.forEach { taskList in
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    self.taskLists.append(taskList)
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    index += 1
                }
                delay += 0.35
            }
            
        }
    }
    
    @objc func buttonAddPressed() { showAlert() }
    
    @objc func buttonTrashPressed() {
        let alert = AlertControllerBuilder(title: "Restore Defaults?", message: "App will terminate")
        alert.addActionCancel()
        alert.addAction(title: "Proceed", style: .default) {
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.initialLaunch.rawValue)
            self.storageManager.clearData()
            exit(0)
        }
        present(alert.build(), animated: true)
    }
    
    func save(title: String?) {
        guard let title, !title.isEmpty else {
            let alert = AlertControllerBuilder(title: "Title can't be empty", message: nil)
                .addAction(title: "OK", style: .cancel, handler: nil)
            present(alert.build(), animated: true)
            return
        }
        let taskList = TaskList(title: title)
        storageManager.save(taskList: taskList) {
            self.taskLists.insert(taskList, at: 0)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    func edit(_ taskList: TaskList) {}
    
}

// MARK: Alert
private extension TaskListViewController {
    
    private func showAlert(edit taskList: TaskList? = nil) {
        let alert = AlertControllerBuilder(
            title: "\(taskList == nil ? "New" : "Edit") Task List",
            message: "Enter the title"
        )
        
        alert
            .addTextField(placeholder: "List Title", text: taskList == nil ? nil : "\(taskList?.title ?? "")")
            .addActionCancel()
            .addAction(title: taskList == nil ? "Save" : "Save Shanges", style: .default) { [unowned self] in
                taskList == nil ? save(title: alert.firstTextFieldText()) : edit(taskList!)
            }
        
        present(alert.build(), animated: true)
    }
    
}

// MARK: UI Methods
private extension TaskListViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        title = ViewControllers.taskListVC.title
        
        navigationController?.navigationBar.prefersLargeTitles = true
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(white: 1, alpha: 0.5)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationItem.backButtonTitle = "List"
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonAddPressed)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(buttonTrashPressed))
        ]
        setupSubviews(segmentedControl, tableView, activityIndicator)
        setupConstraints()
    }
    
    func setupSubviews(_ views: UIView...) {
        views.forEach { view.addSubview($0) }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
        ])
    }
    
}

// MARK: Protocols. UITableView...
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ViewControllers.taskList.cellID, for: indexPath)
        let cell = UITableViewCell(style: .value1, reuseIdentifier: ViewControllers.taskListVC.cellID)
        
        let taskList = taskLists[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = taskList.title
        content.secondaryText = taskList.tasks.count.formatted()
        cell.contentConfiguration = content
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let taskVC = TaskViewController()
        taskVC.taskList = taskLists[indexPath.row]
        navigationController?.pushViewController(taskVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let taskList = taskLists[indexPath.row]
        
        let actionDelete = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.taskLists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let actionEdit = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.edit(taskList)
            isDone(true)
        }
        
        let actionDone = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        actionEdit.backgroundColor = .orange
        actionDone.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [actionDone, actionEdit, actionDelete])
        
    }
    
}
