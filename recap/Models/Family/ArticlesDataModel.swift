//
//  ArticlesDataModel.swift
//  Recap
//
//  Created by khushi on 05/11/24.
//

import UIKit

class Article {
    var title: String
    var author: String
    var content: String
    var image: UIImage
    var link: String
    var source: String
    var citation: String

    init(
        title: String, author: String, content: String, image: UIImage, link: String,
        source: String = "", citation: String = ""
    ) {
        self.title = title
        self.author = author
        self.content = content
        self.image = image
        self.link = link
        self.source = source
        self.citation = citation
    }
}
