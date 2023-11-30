//
//  TaskListViewController.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import UIKit
import RealmSwift

final class TaskListViewController: UIViewController {
    
    // MARK: Properties
    private var storageManager = StorageManager.shared
    private var taskLists: Results<TaskList>!
    
    // MARK: UI
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.insertSegment(withTitle: "Date", at: 0, animated: false)
        control.insertSegment(withTitle: "A-Z", at: 1, animated: false)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
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
        fetchData()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

// MARK: Private Methods
private extension TaskListViewController {
    
    func fetchData() {
        taskLists = storageManager.fetchData(TaskList.self)
        taskLists = taskLists.sorted(by: \TaskList.date, ascending: false)
        activityIndicator.stopAnimating()
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: taskLists = taskLists.sorted(by: \TaskList.date, ascending: false)
        case 1: taskLists = taskLists.sorted(by: \TaskList.title, ascending: true)
        default: break
        }
        tableView.reloadData()
    }
    
    @objc func buttonAddPressed() { showAlert() }
    
    @objc func buttonTrashPressed() {
        let alert = AlertControllerBuilder(title: "Clear Stored Data", message: nil)
        alert.addActionCancel()
        alert.addAction(title: "Proceed", style: .default) {
            self.storageManager.clearData()
            self.tableView.reloadData()
        }
        present(alert.build(), animated: true)
    }
    
    func save(title: String?) {
        guard let title, !title.isEmpty else {
            showAlertError(title: "Title can't be empty")
            return
        }
        
        let taskList = TaskList()
        taskList.title = title
        
        storageManager.save(taskList: taskList) {
            self.tableView.insertRows(at: [IndexPath(row: self.taskLists.index(of: taskList) ?? 0, section: 0)], with: .automatic)
        }
    }
    
    func edit(_ taskList: TaskList, with title: String?) {
        guard let title, !title.isEmpty else {
            showAlertError(title: "Title can't be empty")
            return
        }
        storageManager.edit(taskList: taskList, with: title)
    }
    
}

// MARK: Alert
private extension TaskListViewController {
    
    private func showAlertError(title: String) {
        let alert = AlertControllerBuilder(title: title, message: nil)
            .addAction(title: "OK", style: .cancel, handler: nil)
        present(alert.build(), animated: true)
        return
    }
    
    private func showAlert(edit taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let alert = AlertControllerBuilder(
            title: "\(taskList == nil ? "New" : "Edit") Task List",
            message: "Enter the title"
        )
        
        alert
            .addTextField(placeholder: "List Title", text: taskList == nil ? nil : "\(taskList?.title ?? "")")
            .addActionCancel()
            .addAction(title: taskList == nil ? "Save" : "Save Shanges", style: .default) { [unowned self] in
                if let taskList {
                    edit(taskList, with: alert.firstTextFieldText())
                    completion?()
                } else {
                    save(title: alert.firstTextFieldText())
                }
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
        
        /*
         navigationItem.leftBarButtonItem = editButtonItem
         navigationItem.rightBarButtonItems = [
         UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonAddPressed)),
         UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(buttonTrashPressed))
         ]
         */
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(buttonTrashPressed))
        navigationItem.rightBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(buttonAddPressed))
        
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
        let cell = UITableViewCell(style: .value1, reuseIdentifier: ViewControllers.taskListVC.cellID)
        
        let taskList = taskLists[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = taskList.title
        
        if taskList.isComplete {
            content.secondaryText = nil
            cell.accessoryType = .checkmark
        } else {
            content.secondaryText = taskList.tasks.count.formatted()
            cell.accessoryType = .none
        }
        
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
            self.storageManager.delete(taskList: taskList) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
        
        let actionEdit = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(edit: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let actionDone = UIContextualAction(style: .normal, title: taskList.isComplete ? "Undone" : "Done") { _, _, isDone in
            if taskList.isComplete {
                self.storageManager.undone(taskList: taskList) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    isDone(true)
                }
            } else {
                self.storageManager.done(taskList: taskList) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    isDone(true)
                }
            }
        }
        
        actionEdit.backgroundColor = .orange
        actionDone.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [actionDone, actionEdit, actionDelete])
        
    }
    
}
