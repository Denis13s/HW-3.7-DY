//
//  Enums.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import Foundation

enum UserDefaultsKeys: String {
    case initialLaunch
}

enum ViewControllers {
    case taskListVC
    case taskVC
    
    var title: String {
        switch self {
        case .taskListVC: return "Task List"
        case .taskVC: return "Tasks"
        }
    }
    
    var cellID: String {
        switch self {
        case .taskListVC: return "cellTaskList"
        case .taskVC: return "cellTask"
        }
    }
}

