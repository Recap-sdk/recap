//
//  CategoryPickerViewController.swift
//  recap
//
//  Created by s1834 on 11/03/25.
//

import UIKit

class CategoryPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private let pickerView = UIPickerView()
    private let categories: [String]
    private let completion: (String) -> Void

    init(categories: [String], completion: @escaping (String) -> Void) {
        self.categories = categories
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        pickerView.delegate = self
        pickerView.dataSource = self

        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Done", for: .normal)
        selectButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)

        selectButton.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pickerView)
        view.addSubview(selectButton)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            selectButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func selectCategory() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = categories[selectedRow]
        completion(selectedCategory)
        dismiss(animated: true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { categories.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}
