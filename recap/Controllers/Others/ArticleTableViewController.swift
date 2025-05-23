import FirebaseFirestore
import UIKit

class ArticleTableViewController: UITableViewController {
    private let dataFetch: DataFetchProtocol
    private var articles = [Article]()

    init(dataFetch: DataFetchProtocol = DataFetch()) {
        self.dataFetch = dataFetch
        super.init(nibName: nil, bundle: nil)
    }

    init(preloadedArticles: [Article] = [], dataFetch: DataFetchProtocol = DataFetch()) {
        articles = preloadedArticles
        self.dataFetch = dataFetch
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        dataFetch = DataFetch()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchArticles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Apply background color when view appears
        applyBackgroundColor()
    }

    private func setupUI() {
        title = "Articles"

        tableView.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 317
        
        // Apply background color immediately
        applyBackgroundColor()
    }
    
    private func applyBackgroundColor() {
        if traitCollection.userInterfaceStyle == .light {
            // Subtle grey background for light mode (similar to Apple Health)
            let healthAppGrey = Constants.BGs.GreyBG
            
            // Apply to table view directly
            tableView.backgroundColor = healthAppGrey
            
            // Also apply to parent view to ensure complete coverage
            view.backgroundColor = healthAppGrey
        } else {
            // Default dark mode background
            tableView.backgroundColor = .systemBackground
            view.backgroundColor = .systemBackground
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyBackgroundColor()
        }
    }

    private func fetchArticles() {
        if !articles.isEmpty {
            tableView.reloadData() // Use preloaded data
            return
        }

        dataFetch.fetchArticles { [weak self] fetchedArticles, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if let error = error {
                    self.showErrorAlert(message: "Failed to load articles: \(error.localizedDescription)")
                    return
                }

                if let fetchedArticles = fetchedArticles, !fetchedArticles.isEmpty {
                    self.articles = fetchedArticles
                    self.tableView.reloadData()
                } else {
                    self.showErrorAlert(message: "No articles available at the moment.")
                }
            }
        }
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Retry",
            style: .default,
            handler: { [weak self] _ in
                self?.fetchArticles()
            }
        ))

        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel
        ))

        present(alert, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.identifier,
            for: indexPath
        ) as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: articles[indexPath.row])
        cell.selectionStyle = .none
        
        // Ensure cell background is transparent to show table view background
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        let detailVC = ArticleDetailViewController(article: article)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
