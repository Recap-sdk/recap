//
//  showAlert.swift
//  recap
//
//  Created by Diptayan Jash on 15/12/24.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String, actionTitle: String = "OK", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
            // Only call completion if provided, don't dismiss the view controller
            completion?()
        })
        present(alert, animated: true)
    }
}
