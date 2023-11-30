//
//  StorageManager.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import Foundation
import RealmSwift

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
}

extension StorageManager {
    
    func fetchData<T>(_ type: T.Type) -> Results<T> where T: RealmFetchable {
        
        if type is TaskList.Type, UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunch.rawValue) {
            write { realm.add(TaskList.examples()) }
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.initialLaunch.rawValue)
        }
        
        return realm.objects(T.self)
    }
    
    func clearData(completion: (() -> Void)? = nil) {
        write {
            realm.deleteAll()
            completion?()
        }
    }
    
    func clearTasks(for taskList: TaskList, completion: (() -> Void)? = nil) {
        write {
            realm.delete(taskList.tasks)
            completion?()
        }
    }
    
}

extension StorageManager {
    
    // MARK: TaskList
    func save(taskList: TaskList, completion: (() -> Void)? = nil) {
        write {
            realm.add(taskList)
            completion?()
        }
    }
    
    func edit(taskList: TaskList, with title: String, completion: (() -> Void)? = nil) {
        write {
            taskList.title = title
            completion?()
        }
    }
    
    func undone(taskList: TaskList, completion: (() -> Void)? = nil) {
        write {
            taskList.setValue(false, forKey: TaskListKeys.isComplete.rawValue)
            taskList.tasks.setValue(false, forKey: TaskKeys.isComplete.rawValue)
            completion?()
        }
    }
    
    func done(taskList: TaskList, completion: (() -> Void)? = nil) {
        write {
            taskList.setValue(true, forKey: TaskListKeys.isComplete.rawValue)
            taskList.tasks.setValue(true, forKey: TaskKeys.isComplete.rawValue)
            completion?()
        }
    }
    
    func delete(taskList: TaskList, completion: (() -> Void)? = nil) {
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
            completion?()
        }
    }
    
    // MARK: Task
    func save(task: Task, to taskList: TaskList, completion: (() -> Void)? = nil) {
        write {
            taskList.tasks.append(task)
            taskList.isComplete = false
            completion?()
        }
    }
    
    func edit(taskList: TaskList, for task: Task, with title: String, and description: String?, completion: (() -> Void)? = nil) {
        write {
            if let index = taskList.tasks.index(of: task) {
                taskList.tasks[index].title = title
                taskList.tasks[index].note = description ?? ""
                completion?()
            }
        }
    }
    
    func undone(taskList: TaskList, for task: Task, completion: (() -> Void)? = nil) {
        write {
            if let index = taskList.tasks.index(of: task) {
                taskList.tasks[index].isComplete = false
                
                taskList.isComplete = false
                
                completion?()
            }
        }
    }
    
    func done(taskList: TaskList, for task: Task, completion: (() -> Void)? = nil) {
        write {
            if let index = taskList.tasks.index(of: task) {
                taskList.tasks[index].isComplete = true
                
                updateIsComplete(for: taskList)
                
                completion?()
            }
        }
    }
    
    func delete(taskList: TaskList, for task: Task, completion: (() -> Void)? = nil)  {
        write {
            if let index = taskList.tasks.index(of: task) {
                realm.delete(taskList.tasks[index])
                completion?()
            }
        }
    }
    
}

private extension StorageManager {
    
    func updateIsComplete(for taskList: TaskList) {
        for task in taskList.tasks {
            if !task.isComplete {
                taskList.isComplete = false
                return
            }
        }
        
        taskList.isComplete = true
    }
    
    func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
