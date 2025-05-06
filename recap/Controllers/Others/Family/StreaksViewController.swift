//
//  StreaksViewController.swift
//  recap_home
//
//  Created by s1834 on 19/11/24.
//

import UIKit

class StreaksViewController: UIViewController {
    let headerView = UIView()
    let streakStatsView = UIView()
    let calendarView = UIView()
    var calendarCollectionView: UICollectionView!
    let monthYearLabel = UILabel()
    let previousMonthButton = UIButton()
    let nextMonthButton = UIButton()

    var currentMonth: Int = 11
    var currentYear: Int = 2024
    var maxStreakLabel: UILabel!
    var currentStreakLabel: UILabel!
    var activeDaysLabel: UILabel!

    var streakDates: [String: Bool] = [:]

    private var verifiedUserDocID: String
    var streakService: StreakService!
    
    private var infoCard: UIView?
    private var blurredView: UIVisualEffectView?
    private var isInfoCardVisible = false
    
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        self.calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
        self.streakService = StreakService(verifiedUserDocID: self.verifiedUserDocID)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.BGs.GreyBG
        let currentDate = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        currentYear = currentComponents.year!
        currentMonth = currentComponents.month!
        
        view.backgroundColor = .white
        setupNavBar()
        setupProfileView()
        setupHeaderView()
        setupCalendarView()
        
        streakService = StreakService(verifiedUserDocID: verifiedUserDocID)
        streakService.streakDataFetched = { [weak self] maxStreak, currentStreak, activeDays in
                   self?.updateStreakStats(maxStreak: maxStreak, currentStreak: currentStreak, activeDays: activeDays)
               }
        
        fetchAndUpdateStreakData()
        setupStreakStatsView()
        streakService.fetchAndUpdateStreakStats()
    }
    
    func fetchAndUpdateStreakData() {
        let yearMonth = formattedYearMonth()

        streakService.getStreaksForUser(yearMonth: yearMonth) { [weak self] streak in
            guard let self = self else { return }

            if let streak = streak {
                self.streakDates = streak.streakDates
            } else {
                print("⚠️⚠️ No streak data found for \(yearMonth), but not uploading default data.")
            }
            
            DispatchQueue.main.async {
                self.calendarCollectionView.reloadData()
            }
        }
    }

    @objc func handlePreviousMonth() {
        if currentMonth > 1 {
            currentMonth -= 1
        } else {
            currentMonth = 12
            currentYear -= 1
        }
        fetchAndUpdateStreakData()
        monthYearLabel.text = formattedMonthYear()
    }

    @objc func handleNextMonth() {
        let calendar = Calendar.current
        let currentDate = Date()
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)

        if currentYear < currentComponents.year! || (currentYear == currentComponents.year! && currentMonth < currentComponents.month!) {
            currentMonth += 1
            if currentMonth > 12 {
                currentMonth = 1
                currentYear += 1
            }
            fetchAndUpdateStreakData()
            monthYearLabel.text = formattedMonthYear()
        }
    }
}
