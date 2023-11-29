//
//  Models.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import Foundation

final class TaskList {
    var title: String
    var date = Date()
    var tasks: [Task] = []
    
    init(title: String) {
        self.title = title
    }
}

final class Task {
    var title: String
    var note: String?
    var date = Date()
    var isComplete = false
    
    init(title: String, note: String? = nil) {
        self.title = title
        self.note = note
    }
}

extension TaskList {
    static func examples() -> [TaskList] {
        let taskList1 = TaskList(title: "Housework-1 [Example]")
        taskList1.tasks = Task.examples()
        let taskList2 = TaskList(title: "Housework-2 [Example]")
        taskList2.tasks = Task.examples()
        let taskList3 = TaskList(title: "Housework-3 [Example]")
        taskList3.tasks = Task.examples()
        return [taskList1, taskList2, taskList3]
    }
}

extension Task {
    static func examples() -> [Task] {
        let task1 = Task(title: "Brush teeth [Example]")
        let task2 = Task(title: "Wash dishes [Example]", note: "Very important task")
        let task3 = Task(title: "Make a bed [Example]")
        task3.isComplete = true
        return [task1, task2, task3]
    }
}
