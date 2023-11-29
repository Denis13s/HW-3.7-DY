//
//  Enums.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import Foundation

enum ViewControllers {
    case taskList
    case tasks
    
    var title: String {
        switch self {
        case .taskList: return "Task List"
        case .tasks: return "Tasks"
        }
    }
    
    var cellID: String {
        switch self {
        case .taskList: return "cellTaskList"
        case .tasks: return "cellTask"
        }
    }
}

