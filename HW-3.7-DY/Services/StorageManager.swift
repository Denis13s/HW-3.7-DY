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
    
    func fetchData(completion: ((Results<TaskList>) -> Void)) {
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunch.rawValue) {
            print("It's the first App launch")
            TaskList.examples().forEach { self.save(taskList: $0) }
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.initialLaunch.rawValue)
        }
        else {
            print("It's not the first App launch")
        }
        
        completion(self.realm.objects(TaskList.self))
            
            
            
//            if let data = realm.objects(type) {
//                DispatchQueue.main.async {
//                    if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunch.rawValue) {
//                        TaskList.examples().forEach { save(taskList: $0, completion: nil) }
//                        
//                    } else {
//                        completion?(data)
//                    }
//                }
//            } else {
//                print("Wrong type for fetching data")
//            }
//        }
    }
    
    func clearData(completion: (() -> Void)? = nil) {
        write {
            realm.deleteAll()
            completion?()
        }
    }
    
}

extension StorageManager {
    
    // MARK: TaskList
    func save(taskList: TaskList, completion: (() -> Void)? = nil) {
        //        taskLists.append(taskList)
        write {
            let taskList = TaskList(value: taskList)
            realm.add(taskList)
            completion?()
        }
    }
    
    func edit(taskList: TaskList, with title: String, completion: (() -> Void)? = nil) {
        //        taskLists.first { $0 === taskList }?.title = title
        write {
            taskList.title = title
            completion?()
        }
    }
    
    func done(taskList: TaskList, completion: (() -> Void)? = nil) {
        //        taskLists.first { $0 === taskList }?.tasks.forEach { $0.isComplete = true }
        write {
            taskList.tasks.setValue(true, forKey: TaskKeys.isComplete.rawValue)
            completion?()
        }
    }
    
    func delete(taskList: TaskList, completion: (() -> Void)? = nil) {
        //        taskLists.removeAll { $0 === taskList }
        write {
            realm.delete(taskList.tasks)
            realm.delete(taskList)
            completion?()
        }
    }
    
    // MARK: Task
    func save(task: Task, to taskList: TaskList, completion: (() -> Void)? = nil) {
        //        taskLists.first { $0 === taskList }?.tasks.insert(task, at: 0)
        write {
            taskList.tasks.append(task)
            completion?()
        }
    }
    
}

private extension StorageManager {
    
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
