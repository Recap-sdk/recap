//
//  StreaksViewController.swift
//  recap_home
//
//  Created by user@47 on 19/11/24.
//

import UIKit

class StreaksViewController: UIViewController {
    let headerView = UIView()
    let streakStatsView = UIView()
    let calendarView = UIView()
    let calendarCollectionView: UICollectionView!
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

        print("✅ StreaksViewController initialized with User Doc ID: \(self.verifiedUserDocID)")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let currentDate = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        currentYear = currentComponents.year!
        currentMonth = currentComponents.month!
        
        view.backgroundColor = .white
        setupGradientBackground()
        setupNavBar()
        setupProfileView()
//        setupStreakStatsView()
        setupHeaderView()
        setupCalendarView()
        
        // Initialize the StreakService
        streakService = StreakService(verifiedUserDocID: verifiedUserDocID)
        streakService.streakDataFetched = { [weak self] maxStreak, currentStreak, activeDays in
                   self?.updateStreakStats(maxStreak: maxStreak, currentStreak: currentStreak, activeDays: activeDays)
               }
        // Fetch and update streak data from Firestore when view loads
        fetchAndUpdateStreakData()
        setupStreakStatsView()
//        streakService.fetchUserStreakData()
        streakService.fetchAndPrintStreakData()
//        addNovember2024StreakData()
    }
    
    func fetchAndUpdateStreakData() {
        let yearMonth = formattedYearMonth()
        
        streakService.getStreaksForUser(yearMonth: yearMonth) { [weak self] streak in
            guard let self = self else { return }
            
            if let streak = streak {
                self.updateStreakDatesWithStreaks(streak.streakDates)
            } else {
                print("⚠️ No streak data found for \(yearMonth), but not uploading default data.")
            }
            
            DispatchQueue.main.async {
                self.calendarCollectionView.reloadData()
            }
        }
    }


    
    func uploadDefaultStreakData(for yearMonth: String) {
          guard !yearMonth.isEmpty else {
              print("Error: Year-Month string is empty.")
              return
          }

          let defaultMonth = "02"
          let currentYear = Calendar.current.component(.year, from: Date())
          let febYearMonth = "\(currentYear)-\(defaultMonth)"
          
          var defaultStreaks: [String: Bool] = [:]
          let numberOfDaysInFebruary = daysInMonth(year: currentYear, month: 2)
          
          // Create streaks for February, setting odd days as streak days
          for day in 1...numberOfDaysInFebruary {
              let date = String(format: "%02d", day)
              defaultStreaks["\(febYearMonth)-\(date)"] = day % 2 == 1
          }
          
        streakService.updateStreaksForUser(streaks: defaultStreaks) { success in
              if success {
                  print("✅ Default streak data for February uploaded successfully.")
                  // self.updateStreakDatesWithStreaks(defaultStreaks)
              } else {
                  print("❌ Failed to upload default streak data.")
              }
          }
      }

    func updateStreakDatesWithStreaks(_ streaks: [String: Bool]) {
        // Clear any existing streak data
        streakDates.removeAll()
        
        // Update the streakDates with the fetched streak data
        for (dateStr, isCompleted) in streaks {
            streakDates[dateStr] = isCompleted
        }
        
        // Reload the collection view to reflect updated streak data
        calendarCollectionView.reloadData()
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
