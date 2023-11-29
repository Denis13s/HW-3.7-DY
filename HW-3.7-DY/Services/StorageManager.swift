//
//  StorageManager.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import Foundation

final class StorageManager {
    
    static let shared = StorageManager()
    
    private var taskLists = [TaskList]()
    
    private init() {}
    
}

extension StorageManager {
    
    func fetchData<T>(type: T.Type, completion: ((T) -> Void)?) {
        // Mimic delay for fetching data
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            if let data = self.taskLists as? T {
                DispatchQueue.main.async {
                    if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunch.rawValue) {
                        self.taskLists = TaskList.examples()
                        completion?(self.taskLists as! T)
                    } else {
                        completion?(data)
                    }
                }
            } else {
                print("Wrong type for fetching data")
            }
        }
    }
    
    func clearData() {
        taskLists = []
    }
    
}

extension StorageManager {
    
    // MARK: TaskList
    func save(taskList: TaskList, completion: (() -> Void)?) {
        taskLists.append(taskList)
        completion?()
    }
    
    func edit(taskList: TaskList, with title: String, completion: (() -> Void)?) {
        taskLists.first { $0 === taskList }?.title = title
        completion?()
    }
    
    func done(taskList: TaskList, completion: (() -> Void)?) {
        taskLists.first { $0 === taskList }?.tasks.forEach { $0.isComplete = true }
        completion?()
    }
    
    func delete(taskList: TaskList, completion: (() -> Void)?) {
        taskLists.removeAll { $0 === taskList }
        completion?()
    }
    
    // MARK: Task
    func save(task: Task, to taskList: TaskList, completion: (() -> Void)?) {
        taskLists.first { $0 === taskList }?.tasks.insert(task, at: 0)
        completion?()
    }
                            
}
