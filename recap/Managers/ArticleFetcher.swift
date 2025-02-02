//
//  ArticleFetcher.swift
//  Recap
//
//  Created by user@47 on 15/01/25.
//

import FirebaseFirestore
import UIKit

class ArticleFetcher {
    
    private let db = Firestore.firestore()

    // Fetch articles from Firestore
    func fetchArticles(completion: @escaping ([Article]?, Error?) -> Void) {
        db.collection("Articles").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var articles = [Article]()
            for document in snapshot!.documents {
                let data = document.data()
                if let title = data["title"] as? String,
                   let author = data["author"] as? String,
                   let content = data["content"] as? String,
                   let imageUrl = data["image"] as? String,
                   let link = data["link"] as? String {
                    
                    // Fetch image asynchronously
                    self.fetchImage(from: imageUrl) { image in
                        let article = Article(
                            title: title,
                            author: author,
                            content: content,
                            image: image ?? UIImage(),  // Default to an empty image if fetching fails
                            link: link
                        )
                        articles.append(article)
                        
                        // Call completion handler after all articles are fetched
                        if articles.count == snapshot!.documents.count {
                            completion(articles, nil)
                        }
                    }
                }
            }
        }
    }

    // Helper method to fetch the image
    private func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(image)
        }
        task.resume()
    }
}
