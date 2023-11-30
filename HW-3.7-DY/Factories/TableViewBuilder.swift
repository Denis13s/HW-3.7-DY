//
//  TableViewBuilder.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import UIKit

final class TableViewBuilder {
    
    private let tableView: UITableView
    
    init(cellID: String, self: UITableViewDataSource & UITableViewDelegate) {
        tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func build() -> UITableView {
        return tableView
    }
    
}
