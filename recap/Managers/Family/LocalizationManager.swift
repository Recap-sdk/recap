//
//  LocalizationManager.swift
//  recap
//
//  Created by Diptayan Jash on 11/02/25.
//

import Foundation
class LocalizationManager {
    static let shared = LocalizationManager()
    
    func localizedString(for key: String) -> String {
        let language = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
