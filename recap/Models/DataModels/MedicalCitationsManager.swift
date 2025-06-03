//
//  MedicalCitationsManager.swift
//  recap
//
//  Created on 03/06/25.
//

import Foundation

class MedicalCitationsManager {
    static let shared = MedicalCitationsManager()

    private init() {
        loadCitations()
    }

    private(set) var allCitations: [Citation] = []
    private let dataFetch = DataFetch()
    private var isLoading = false

    // MARK: - Data Loading

    private func loadCitations() {
        isLoading = true

        dataFetch.fetchCitations { [weak self] citations, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching citations from Firebase: \(error.localizedDescription)")
                return
            }

            if let citations = citations, !citations.isEmpty {
                self.allCitations = citations
            } else {
                print("No citations found in Firebase")
            }

            self.isLoading = false

            NotificationCenter.default.post(
                name: Notification.Name("CitationsUpdated"), object: nil)
        }
    }

    func refreshCitations(completion: @escaping (Bool) -> Void) {
        if isLoading {
            completion(false)
            return
        }

        isLoading = true

        dataFetch.fetchCitations { [weak self] citations, error in
            guard let self = self else {
                completion(false)
                return
            }

            if let error = error {
                print("Error refreshing citations: \(error.localizedDescription)")
                self.isLoading = false
                completion(false)
                return
            }

            if let citations = citations, !citations.isEmpty {
                self.allCitations = citations
                self.isLoading = false
                completion(true)

                // Post notification that citations are updated
                NotificationCenter.default.post(
                    name: Notification.Name("CitationsUpdated"), object: nil)
            } else {
                self.isLoading = false
                completion(false)
            }
        }
    }

    // MARK: - Helper Methods

    func getMemoryAssessmentCitation() -> String {
        guard let primaryCitation = allCitations.first else {
            return "Source information is being loaded..."
        }
        return "Source: \(primaryCitation.formattedCitation)"
    }

    func getAllMemoryCitations() -> String {
        guard !allCitations.isEmpty else {
            return "No citations available."
        }

        return allCitations.map { $0.formattedCitation }.joined(separator: "\n\n")
    }

    func getMedicalDisclaimer() -> String {
        return """
            Medical Disclaimer: The information provided is for educational purposes only and is not intended as medical advice. Always consult with a healthcare professional before making any medical decisions.

            The memory assessment information is based on established research in the field of cognitive psychology and neuroscience. See "Citations" for detailed sources.
            """
    }
}
