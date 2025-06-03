//
//  citations.swift.swift
//  recap
//
//  Created by Diptayan Jash on 03/06/25.
//

import Foundation
struct Citation {
    let title: String
    let source: String
    let authors: String
    let journal: String
    let year: String
    let doi: String?
    let url: URL?

    var formattedCitation: String {
        var citation = "\(authors) (\(year)). \(title). \(journal)."
        if let doi = doi {
            citation += " DOI: \(doi)"
        }
        return citation
    }
}
