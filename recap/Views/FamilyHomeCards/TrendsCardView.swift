//
//  SegmentedViewController.swift
//  Recap
//
//  Created by admin70 on 15/01/25.
//

import UIKit
import SwiftUI

class TrendsCardView: UIView {
    private let immediateGraphView = UIView()
    private let recentGraphView = UIView()
    private let remoteGraphView = UIView()
    private let segmentedControl = UISegmentedControl(items: ["Immediate", "Recent", "Remote"])
    
    private let immediateInsightsButton = UIButton()
    private let recentInsightsButton = UIButton()
    private let remoteInsightsButton = UIButton()
    
    private var immediateMemoryData: [ImmediateMemoryData] = []
    private var recentMemoryData: [RecentMemoryData] = []
    private var remoteMemoryData: [RemoteMemoryData] = []
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
    
    var onGraphTap: ((Int) -> Void)?
    var onInsightsTap: ((Int) -> Void)?
    
    private var verifiedUserDocID: String
    
    init(frame: CGRect, verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        super.init(frame: frame)
        setupUI()
        setupTapGestures()
        fetchAllMemoryData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        setupUI()
        
        setupTapGestures()
    }
    
    private func setupUI() {
        self.backgroundColor = AppColors.cardBackgroundColor
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Trends"
        titleLabel.textColor = AppColors.primaryTextColor
        titleLabel.font = Constants.FontandColors.titleFont
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(segmentedControl)
        
        setupInsightsButton(immediateInsightsButton, title: "View Immediate Insights", tag: 1)
        setupInsightsButton(recentInsightsButton, title: "View Recent Insights", tag: 2)
        setupInsightsButton(remoteInsightsButton, title: "View Remote Insights", tag: 3)
        
        self.addSubview(immediateGraphView)
        self.addSubview(recentGraphView)
        self.addSubview(remoteGraphView)
        self.addSubview(immediateInsightsButton)
        self.addSubview(recentInsightsButton)
        self.addSubview(remoteInsightsButton)
        
        immediateGraphView.isHidden = false
        recentGraphView.isHidden = true
        remoteGraphView.isHidden = true
        immediateInsightsButton.isHidden = false
        recentInsightsButton.isHidden = true
        remoteInsightsButton.isHidden = true
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            immediateGraphView.topAnchor.constraint(equalTo: self.topAnchor, constant: 110),
            immediateGraphView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            immediateGraphView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            immediateGraphView.heightAnchor.constraint(equalToConstant: 300),
            immediateGraphView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -100),
            
            immediateInsightsButton.topAnchor.constraint(equalTo: immediateGraphView.bottomAnchor, constant: 8),
            immediateInsightsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            immediateInsightsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            immediateInsightsButton.heightAnchor.constraint(equalToConstant: 44),
            
            recentGraphView.topAnchor.constraint(equalTo: self.topAnchor, constant: 110),
            recentGraphView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            recentGraphView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            recentGraphView.heightAnchor.constraint(equalToConstant: 300),
            recentGraphView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -100),
            
            recentInsightsButton.topAnchor.constraint(equalTo: recentGraphView.bottomAnchor, constant: 8),
            recentInsightsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            recentInsightsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            recentInsightsButton.heightAnchor.constraint(equalTo: immediateInsightsButton.heightAnchor),
            
            remoteGraphView.topAnchor.constraint(equalTo: self.topAnchor, constant: 110),
            remoteGraphView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            remoteGraphView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            remoteGraphView.heightAnchor.constraint(equalToConstant: 300),
            remoteGraphView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -100),
            
            remoteInsightsButton.topAnchor.constraint(equalTo: remoteGraphView.bottomAnchor, constant: 8),
            remoteInsightsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            remoteInsightsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            remoteInsightsButton.heightAnchor.constraint(equalTo: immediateInsightsButton.heightAnchor)
        ])
    }
    
    private func setupInsightsButton(_ button: UIButton, title: String, tag: Int) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = AppColors.primaryButtonColor
        button.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = tag
        button.addTarget(self, action: #selector(handleInsightsTap(_:)), for: .touchUpInside)
    }
    
    private func fetchAllMemoryData() {
        fetchImmediateMemoryData(for: verifiedUserDocID) { data in
            DispatchQueue.main.async {
                self.immediateMemoryData = data
                self.setupGraph(self.immediateGraphView, chartType: "donut", data: data)
            }
        }
        
        fetchRecentMemoryData(for: verifiedUserDocID, selectedMonth: "March") { data in
            DispatchQueue.main.async {
                self.recentMemoryData = data
                self.setupGraph(self.recentGraphView, chartType: "bar", data: data)
            }
        }
        
        fetchRemoteMemoryData(for: verifiedUserDocID, month: currentMonth) { data in
            DispatchQueue.main.async {
                self.remoteMemoryData = data
                self.setupGraph(self.remoteGraphView, chartType: "line", data: data)
            }
        }
    }
  
    private func setupGraph(_ containerView: UIView, chartType: String, data: Any?) {
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        var hostingController: UIHostingController<AnyView>?
        
        switch chartType {
        case "donut":
            if let immediateData = data as? [ImmediateMemoryData] {
                // Always create a data point for today, even if we need to use 0 values
                let today = Date()
                
                // Try to get today's data if it exists
                let todayString = { () -> String in
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: today)
                }()
                
                let todayData = immediateData.first(where: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: $0.date) == todayString
                })
                
                // Use today's data if available, otherwise create empty data for today
                let dataToDisplay = todayData ?? ImmediateMemoryData(
                    date: today,
                    correctAnswers: 0,
                    incorrectAnswers: 0,
                    status: .processing
                )
                
                let donutChart = ModernDonutChartView(
                    correctAnswers: dataToDisplay.correctAnswers,
                    incorrectAnswers: dataToDisplay.incorrectAnswers
                )
                hostingController = UIHostingController(rootView: AnyView(donutChart))
            }
        case "bar":
            // Rest of your code remains unchanged
            if let recentData = data as? [RecentMemoryData] {
                let barChart = BarChartView(data: recentData)
                hostingController = UIHostingController(rootView: AnyView(barChart))
            }
        case "line":
            if let remoteData = data as? [RemoteMemoryData] {
                let lineChart = LineChartView(data: remoteData)
                hostingController = UIHostingController(rootView: AnyView(lineChart))
            }
        default:
            return
        }
        
        guard let hostView = hostingController?.view else { return }
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.backgroundColor = .clear
        containerView.addSubview(hostView)
        
        NSLayoutConstraint.activate([
            hostView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            hostView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            hostView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            hostView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
        ])
    }
    
    private func setupTapGestures() {
        [immediateGraphView, recentGraphView, remoteGraphView].enumerated().forEach { index, view in
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.tag = index + 1
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            onGraphTap?(tag)
        }
    }
    
    @objc private func handleInsightsTap(_ sender: UIButton) {
        onInsightsTap?(sender.tag)
    }
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        immediateGraphView.isHidden = sender.selectedSegmentIndex != 0
        recentGraphView.isHidden = sender.selectedSegmentIndex != 1
        remoteGraphView.isHidden = sender.selectedSegmentIndex != 2
        
        immediateInsightsButton.isHidden = sender.selectedSegmentIndex != 0
        recentInsightsButton.isHidden = sender.selectedSegmentIndex != 1
        remoteInsightsButton.isHidden = sender.selectedSegmentIndex != 2
    }
    
    private func fetchRecentMemoryData(for verifiedUserDocID: String, selectedMonth: String, completion: @escaping ([RecentMemoryData]) -> Void) {
        let allDaysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var weeklyData: [RecentMemoryData] = allDaysOfWeek.map { RecentMemoryData(day: $0, correctAnswers: 0, incorrectAnswers: 0) }
        
        // Simulate fetching data (replace with actual Firestore call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(weeklyData)
        }
    }
}
