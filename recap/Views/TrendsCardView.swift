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

    var onGraphTap: ((Int) -> Void)?
    var onInsightsTap: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupTapGestures()
    }

    private func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "Trends"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)

        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(segmentedControl)

        setupGraph(immediateGraphView, correctAnswers: 8, incorrectAnswers: 2, chartType: "donut")
        setupGraph(recentGraphView, correctAnswers: 0, incorrectAnswers: 0, chartType: "bar", data: recentMemoryData)
        setupGraph(remoteGraphView, correctAnswers: 0, incorrectAnswers: 0, chartType: "line", data: novemberReports)

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

            immediateGraphView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            immediateGraphView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            immediateGraphView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            immediateGraphView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.5), // 50% of total height

            immediateInsightsButton.topAnchor.constraint(equalTo: immediateGraphView.bottomAnchor, constant: 8),
            immediateInsightsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            immediateInsightsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            immediateInsightsButton.heightAnchor.constraint(equalToConstant: 44), // Fixed button height

            recentGraphView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            recentGraphView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            recentGraphView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            recentGraphView.heightAnchor.constraint(equalTo: immediateGraphView.heightAnchor),

            recentInsightsButton.topAnchor.constraint(equalTo: recentGraphView.bottomAnchor, constant: 8),
            recentInsightsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            recentInsightsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            recentInsightsButton.heightAnchor.constraint(equalTo: immediateInsightsButton.heightAnchor),

            remoteGraphView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
            remoteGraphView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            remoteGraphView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            remoteGraphView.heightAnchor.constraint(equalTo: immediateGraphView.heightAnchor),

            remoteInsightsButton.topAnchor.constraint(equalTo: remoteGraphView.bottomAnchor, constant: 8),
            remoteInsightsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            remoteInsightsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            remoteInsightsButton.heightAnchor.constraint(equalTo: immediateInsightsButton.heightAnchor),
        ])
    }

    private func setupInsightsButton(_ button: UIButton, title: String, tag: Int) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = tag
        button.addTarget(self, action: #selector(handleInsightsTap(_:)), for: .touchUpInside)
    }

    private func setupGraph(_ containerView: UIView, correctAnswers: Int, incorrectAnswers: Int, chartType: String, data: Any? = nil) {
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.cornerRadius = 8
        containerView.translatesAutoresizingMaskIntoConstraints = false

        var hostingController: UIHostingController<AnyView>?

        switch chartType {
        case "donut":
            let donutChart = DonutChartView(correctAnswers: correctAnswers, incorrectAnswers: incorrectAnswers)
            hostingController = UIHostingController(rootView: AnyView(donutChart))
        case "bar":
            if let recentMemoryData = data as? [RecentMemoryData] {
                let barChart = BarChartView(data: recentMemoryData)
                hostingController = UIHostingController(rootView: AnyView(barChart))
            }
        case "line":
            if let monthlyReportData = data as? [MonthlyReport] {
                let lineChart = LineChartView(data: monthlyReportData, threshold: 7)
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
}

#Preview {
    TrendsCardView()
}
