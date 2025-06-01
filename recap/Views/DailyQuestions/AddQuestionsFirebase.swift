//
//  AddQuestionsFirebase.swift
//  recap
//
//  Created by s1834 on 10/03/25.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit

extension AddQuestionViewController {
    private func setupLayout() {
        view.addSubview(questionTextField)
        view.addSubview(addImageButton)
        view.addSubview(imageView)
        optionTextFields.forEach { view.addSubview($0) }
        view.addSubview(saveButton)
        view.addSubview(cancelImageButton)

        NSLayoutConstraint.activate([
            cancelImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -10),
            cancelImageButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            cancelImageButton.widthAnchor.constraint(equalToConstant: 24),
            cancelImageButton.heightAnchor.constraint(equalToConstant: 24),
        ])

        NSLayoutConstraint.activate([
            questionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: addImageButton.leadingAnchor, constant: -10),
            questionTextField.heightAnchor.constraint(equalToConstant: 50),

            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addImageButton.centerYAnchor.constraint(equalTo: questionTextField.centerYAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 40),
            addImageButton.heightAnchor.constraint(equalToConstant: 40),

            imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])

        for (index, optionTextField) in optionTextFields.enumerated() {
            NSLayoutConstraint.activate([
                optionTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: CGFloat(10 + index * 55)),
                optionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                optionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                optionTextField.heightAnchor.constraint(equalToConstant: 50),
            ])
        }

        if let lastOption = optionTextFields.last {
            // Use categoryButton and timeFrameButton instead of categoryTextField and timeFrameTextField
            let buttonStack = UIStackView(arrangedSubviews: [categoryButton, timeFrameButton])
            buttonStack.axis = .horizontal // Set the axis explicitly
            buttonStack.spacing = 20
            buttonStack.alignment = .fill // Set the alignment explicitly
            buttonStack.distribution = .fillEqually // Set the distribution explicitly
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(buttonStack)

            NSLayoutConstraint.activate([
                buttonStack.topAnchor.constraint(equalTo: lastOption.bottomAnchor, constant: 30),
                buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                buttonStack.heightAnchor.constraint(equalToConstant: 50),
            ])

            NSLayoutConstraint.activate([
                saveButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
                saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                saveButton.widthAnchor.constraint(equalToConstant: 250),
                saveButton.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }

    @objc func saveQuestion() {
        guard let category = selectedCategory else {
            showAlert(title: "⚠️⚠️ Missing Category", message: "Please select a category before saving.📌")
            return
        }

        guard let selectedTimeFrame = selectedTimeFrame else {
            showAlert(title: "⏰⏰ Missing Time Frame", message: "Please select a time frame before saving.")
            return
        }

        let questionText = questionTextField.text ?? ""
        let optionTexts = optionTextFields.map { $0.text ?? "" }
        let filledOptions = optionTexts.filter { !$0.isEmpty }

        guard !questionText.isEmpty, !optionTexts.contains(where: { $0.isEmpty }) else {
            showAlert(title: "📝📝 Incomplete Fields", message: "Please fill in all fields before saving.")
            return
        }

        guard filledOptions.count >= 2 else {
            showAlert(title: "⚠️⚠️ Incomplete Options", message: "Please provide at least 2 options.")
            return
        }

        let askInterval: Int
        switch category {
        case "Immediate": askInterval = 14400
        case "Recent": askInterval = 86400
        case "Remote": askInterval = 31536000
        default: askInterval = 21600
        }

        let timeFrame: (from: String, to: String)
        switch selectedTimeFrame {
        case "Morning": timeFrame = ("06:00", "11:59")
        case "Afternoon": timeFrame = ("12:00", "17:59")
        case "Evening": timeFrame = ("18:00", "23:59")
        case "Night": timeFrame = ("00:00", "05:59")
        default:
            showAlert(title: "⏰⏰ Invalid Time Frame", message: "Please select a valid time frame.")
            return
        }

        let imageUrl = selectedImageURL ?? nil
        let audioUrl = selectedAudioURL ?? nil
        let newQuestion: [String: Any] = ["text": questionText, "category": category.lowercased(), "subcategory": "familyAdded", "tag": "custom", "answerOptions": filledOptions, "answers": [], "correctAnswers": [], "image": imageUrl as Any, "audio": audioUrl as Any, "isAnswered": false, "askInterval": askInterval, "timeFrame": ["from": timeFrame.from, "to": timeFrame.to], "priority": 10, "isActive": true, "hint": questionText, "confidence": NSNull(), "hardness": 2, "questionType": "singleCorrect"]

        let db = Firestore.firestore()
        db.collection("users").document(verifiedUserDocID).collection("questions").addDocument(data: newQuestion) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save question: \(error.localizedDescription)")
                return
            }

            db.collection("familyAddedQuestions").addDocument(data: newQuestion) { familyError in
                if let familyError = familyError {
                    self.showAlert(title: "Error", message: "Question saved to user list, but failed to save in family collection: \(familyError.localizedDescription)")
                } else {
                    self.saveButton.setTitle("Saved", for: .normal)
                    self.saveButton.backgroundColor = .systemGreen
                    // Show success alert and dismiss the view when "OK" is clicked
                    let alert = UIAlertController(title: "✅✅ Success", message: "Question saved successfully!!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        // Dismiss the view controller
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
