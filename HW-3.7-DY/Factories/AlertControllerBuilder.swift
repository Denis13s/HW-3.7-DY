//
//  AlertControllerBuilder.swift
//  HW-3.7-DY
//
//  Created by Denis Yarets on 29/11/2023.
//

import UIKit

final class AlertControllerBuilder {
    
    private let alert: UIAlertController
    
    init(title: String, message: String?) {
        alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        print("\(String(describing: self)): \(#function)")
    }
    
    func build() -> UIAlertController {
        return alert
    }
    
    deinit { print("\(String(describing: self)): \(#function)") }
    
}

extension AlertControllerBuilder {
    
    func firstTextFieldText() -> String? {
        alert.textFields?.first?.text
    }
    
    func lastTextFieldText() -> String? {
        alert.textFields?.last?.text
    }
    
}

extension AlertControllerBuilder {
    
    @discardableResult
    func addTextField(placeholder: String?, text: String?) -> AlertControllerBuilder {
        alert.addTextField {
            if let text {
                $0.placeholder = nil
                $0.text = text
            } else {
                $0.placeholder = placeholder ?? ""
                $0.text = nil
            }
        }
        return self
    }
    
    @discardableResult
    func addAction(title: String, style: UIAlertAction.Style, handler: (() -> Void)?)  -> AlertControllerBuilder {
        let action = UIAlertAction(title: title, style: style) { _ in
                handler?()
        }
        alert.addAction(action)
        return self
    }
    
    @discardableResult
    func addActionCancel() -> AlertControllerBuilder {
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(actionCancel)
        return self
    }
    
}
