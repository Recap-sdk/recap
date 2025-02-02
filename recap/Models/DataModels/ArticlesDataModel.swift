//
//  ArticlesDataModel.swift
//  Recap
//
//  Created by admin70 on 05/11/24.
//

import UIKit

class Article {
    var title: String
    var author: String
    var content: String
    var image: UIImage
    var link: String

    init(title: String, author: String, content: String, image: UIImage, link: String) {
        self.title = title
        self.author = author
        self.content = content
        self.image = image
        self.link = link
    }
}
