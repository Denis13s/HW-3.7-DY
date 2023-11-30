//
//  Models.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import Foundation
import RealmSwift

final class TaskList: Object {
    @Persisted var title = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

final class Task: Object {
    @Persisted var title = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}

extension TaskList {
    static func examples() -> List<TaskList> {
        let examples = List<TaskList>()
        
        let taskList1 = TaskList()
        taskList1.title = "Housework-1 [Example]"
        taskList1.tasks = Task.examples()
        let taskList2 = TaskList()
        taskList2.title = "Housework-2 [Example]"
        taskList2.tasks = Task.examples()
        let taskList3 = TaskList()
        taskList3.title = "Housework-3 [Example]"
        taskList3.tasks = Task.examples()
        
        examples.append(taskList1)
        examples.append(taskList2)
        examples.append(taskList3)
        
        return examples
    }
}

extension Task {
    static func examples() -> List<Task> {
        let examples = List<Task>()
        
        let task1 = Task()
        task1.title = "Brush teeth [Example]"
        let task2 = Task()
        task2.title = "Wash dishes [Example]"
        task2.note = "Very important task"
        let task3 = Task()
        task3.title = "Make a bed [Example]"
        task3.isComplete = true
        
        examples.append(task1)
        examples.append(task2)
        examples.append(task3)
        
        return examples
    }
}
