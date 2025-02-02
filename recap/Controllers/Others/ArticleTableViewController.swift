import UIKit
import FirebaseFirestore

class ArticleTableViewController: UITableViewController {
    var db: Firestore!
    var articles = [Article]()  // This is the array to store fetched articles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize Firestore
        db = Firestore.firestore()
        
        // Fetch articles from Firestore
        fetchArticles()

        // Set up the view
 
        title = "Articles"
        
        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 317
    }

    // Fetch articles from Firestore
    func fetchArticles() {
        let articleFetcher = ArticleFetcher()
        articleFetcher.fetchArticles { [weak self] fetchedArticles, error in
            if let error = error {
                print("Failed to fetch articles: \(error.localizedDescription)")
                return
            }
            
            if let fetchedArticles = fetchedArticles {
                self?.articles = fetchedArticles
                DispatchQueue.main.async {
                    self?.tableView.reloadData()  // Reload table view after fetching
                }
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count  // Return the count of articles
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.identifier, for: indexPath) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: articles[indexPath.row])  // Pass the article data to the cell
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        let detailVC = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.backgroundColor = .clear
    }
}
