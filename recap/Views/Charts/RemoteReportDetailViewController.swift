////
////  RemoteReportDetailViewController.swift
////  recap_charts
////
////  Created by admin70 on 13/11/24.
////
//
//import Charts
//import SwiftUI
//
//struct LineChartView: View {
//    let data: [RemoteMemoryData]
//    @State private var showChartData = false
//
//    var body: some View {
//        VStack {
//            Chart {
//                ForEach(data) { report in
//                    if report.day != "Summary" { // Skip summary for detailed graph
//                        LineMark(
//                            x: .value("Day", report.day),
//                            y: .value("Correct Answers", showChartData ? report.correctAnswers : 0)
//                        )
//                        .foregroundStyle(Color.customLightPurple.gradient)
//                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
//                        .symbol {
//                            Circle()
//                                .fill(Color.customLightPurple)
//                                .frame(width: 8, height: 8)
//                        }
//                        .interpolationMethod(.catmullRom)
//
//                        LineMark(
//                            x: .value("Day", report.day),
//                            y: .value("Incorrect Answers", showChartData ? report.incorrectAnswers : 0)
//                        )
//                        .foregroundStyle(Color.customLightRed.gradient)
//                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
//                        .symbol {
//                            Circle()
//                                .fill(Color.customLightRed)
//                                .frame(width: 8, height: 8)
//                        }
//                        .interpolationMethod(.catmullRom)
//                    }
//                }
//            }
//            .chartYAxis {
//                AxisMarks(position: .leading) { _ in
//                    AxisValueLabel()
//                        .font(.caption)
//                        .foregroundStyle(Color.secondary)
//
//                    AxisGridLine()
//                        .foregroundStyle(Color.secondary.opacity(0.2))
//                }
//            }
//            .chartXAxis {
//                AxisMarks { _ in
//                    AxisValueLabel()
//                        .font(.caption)
//                        .foregroundStyle(Color.secondary)
//                }
//            }
//            .chartForegroundStyleScale([
//                "Correct Answers": Color.customLightPurple.gradient,
//                "Incorrect Answers": Color.customLightRed.gradient,
//            ])
//            .chartLegend(position: .bottom, alignment: .center, spacing: 20)
//            .chartLegend(.visible)
//            .animation(.easeInOut(duration: 1.0), value: showChartData)
//            .frame(height: 250)
//            .padding(.horizontal)
//            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    showChartData = true
//                }
//            }
//        }
//    }
//}
//
//struct RemoteReportDetailViewController: View {
//    let verifiedUserDocID: String
//    @State private var remoteMemoryData: [RemoteMemoryData] = []
//    @State private var isLoading = true
//    @State private var selectedTimeframe = "Month"
//    private let timeframeOptions = ["Week", "Month", "Quarter"]
//
//    private var currentMonth: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//        return formatter.string(from: Date())
//    }
//
//    var body: some View {
//        ZStack {
//            // Modern gradient background with subtle animation
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.95, green: 0.97, blue: 0.99),
//                    Color(red: 0.99, green: 0.95, blue: 0.97),
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Timeframe selector
//                    HStack {
//                        ForEach(timeframeOptions, id: \.self) { option in
//                            Button(action: {
//                                withAnimation {
//                                    selectedTimeframe = option
//                                }
//                            }) {
//                                Text(option)
//                                    .fontWeight(selectedTimeframe == option ? .semibold : .regular)
//                                    .foregroundColor(selectedTimeframe == option ? .white : .primary)
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 16)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 20)
//                                            .fill(selectedTimeframe == option ?
//                                                Color.customLightPurple :
//                                                Color.primary.opacity(0.05))
//                                    )
//                            }
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                    .padding(.horizontal)
//
//                    // Stats summary cards
//                    if let summary = remoteMemoryData.first(where: { $0.day == "Summary" }) {
//                        HStack(spacing: 16) {
//                            // Correct answers card
//                            SummaryCard(
//                                title: "Correct",
//                                value: "\(summary.correctAnswers)",
//                                iconName: "checkmark.circle.fill",
//                                color: .customLightPurple
//                            )
//
//                            // Incorrect answers card
//                            SummaryCard(
//                                title: "Incorrect",
//                                value: "\(summary.incorrectAnswers)",
//                                iconName: "xmark.circle.fill",
//                                color: .customLightRed
//                            )
//                        }
//                        .padding(.horizontal)
//                    }
//
//                    // Chart section with modern card design
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Memory Performance Trend")
//                            .font(.headline)
//                            .padding(.horizontal)
//
//                        if isLoading {
//                            HStack {
//                                Spacer()
//                                ProgressView()
//                                    .scaleEffect(1.5)
//                                    .padding()
//                                Spacer()
//                            }
//                            .frame(height: 250)
//                        } else if remoteMemoryData.isEmpty {
//                            HStack {
//                                Spacer()
//                                VStack(spacing: 16) {
//                                    Image(systemName: "chart.line.downtrend.xyaxis")
//                                        .font(.system(size: 48))
//                                        .foregroundColor(.secondary.opacity(0.6))
//
//                                    Text("No data available for this timeframe")
//                                        .font(.subheadline)
//                                        .foregroundColor(.secondary)
//                                }
//                                .padding()
//                                Spacer()
//                            }
//                            .frame(height: 250)
//                        } else {
//                            LineChartView(data: remoteMemoryData)
//                        }
//                    }
//                    .padding(.vertical)
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color.white.opacity(0.8))
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                    )
//                    .padding(.horizontal)
//
//                    // Performance insights card
//                    if let summary = remoteMemoryData.first(where: { $0.day == "Summary" }) {
//                        VStack(alignment: .leading, spacing: 16) {
//                            HStack {
//                                Image(systemName: "sparkles.rectangle.stack")
//                                    .font(.title2)
//                                    .foregroundColor(.customLightPurple)
//
//                                Text("Performance Insights")
//                                    .font(.title3)
//                                    .fontWeight(.semibold)
//                            }
//
//                            VStack(alignment: .leading, spacing: 10) {
//                                InsightRow(
//                                    iconName: "arrow.up.right",
//                                    color: .green,
//                                    text: "Your highest performance was on day \(getBestPerformanceDay()) with \(getHighestCorrectAnswers()) correct answers."
//                                )
//
//                                Divider()
//
//                                InsightRow(
//                                    iconName: "chart.line.uptrend.xyaxis",
//                                    color: .blue,
//                                    text: "Overall accuracy rate: \(calculateAccuracyRate())%"
//                                )
//                            }
//                            .padding()
//                            .background(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .fill(Color.gray.opacity(0.05))
//                            )
//                        }
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(Color.white.opacity(0.8))
//                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                        )
//                        .padding(.horizontal)
//                    }
//
//                    // About insights section with modern design
//                    VStack(alignment: .leading, spacing: 16) {
//                        HStack {
//                            Image(systemName: "brain.head.profile")
//                                .font(.title2)
//                                .foregroundColor(.purple)
//
//                            Text("About Remote Insights")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                        }
//
//                        Text("Remote memory refers to your ability to recall events or information from the distant past, typically over a week or more.")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//
//                        HStack(alignment: .top, spacing: 12) {
//                            Image(systemName: "chart.xyaxis.line")
//                                .foregroundColor(.blue)
//                                .frame(width: 24, height: 24)
//
//                            Text("By tracking your performance over time, we can observe trends that help you and your caregivers understand how well your long-term memory is functioning.")
//                                .font(.subheadline)
//                                .foregroundColor(.primary)
//                        }
//                    }
//                    .padding(20)
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color.white.opacity(0.8))
//                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//                    )
//                    .padding(.horizontal)
//                }
//                .padding(.bottom, 30)
//            }
//            .navigationTitle("Remote Memory")
//        }
//        .onAppear {
//            print("🟢 RemoteReportDetailViewController appeared. Fetching data...")
//
//            // Simulate loading
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                fetchRemoteMemoryData(for: verifiedUserDocID, month: currentMonth) { data in
//                    DispatchQueue.main.async {
//                        self.isLoading = false
//
//                        if data.isEmpty {
//                            print("⚠️ No data found, setting default values.")
//                            self.remoteMemoryData = [RemoteMemoryData(day: "01", correctAnswers: 0, incorrectAnswers: 0)]
//                        } else {
//                            self.remoteMemoryData = data
//                        }
//                        print("📊 Final Remote Memory Data: \(self.remoteMemoryData)")
//                    }
//                }
//            }
//        }
//    }
//
//    // Helper functions for insights
//    private func getBestPerformanceDay() -> String {
//        let dataPoints = remoteMemoryData.filter { $0.day != "Summary" }
//        if let bestDay = dataPoints.max(by: { $0.correctAnswers < $1.correctAnswers }) {
//            return bestDay.day
//        }
//        return "N/A"
//    }
//
//    private func getHighestCorrectAnswers() -> Int {
//        let dataPoints = remoteMemoryData.filter { $0.day != "Summary" }
//        if let bestDay = dataPoints.max(by: { $0.correctAnswers < $1.correctAnswers }) {
//            return bestDay.correctAnswers
//        }
//        return 0
//    }
//
//    private func calculateAccuracyRate() -> String {
//        if let summary = remoteMemoryData.first(where: { $0.day == "Summary" }) {
//            let total = summary.correctAnswers + summary.incorrectAnswers
//            if total > 0 {
//                let accuracy = Double(summary.correctAnswers) / Double(total) * 100
//                return String(format: "%.1f", accuracy)
//            }
//        }
//        return "0.0"
//    }
//}
//
//// Helper view for summary cards
//struct SummaryCard: View {
//    var title: String
//    var value: String
//    var iconName: String
//    var color: Color
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Image(systemName: iconName)
//                    .foregroundColor(color)
//                    .font(.system(size: 16, weight: .semibold))
//
//                Text(title)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//
//            Text(value)
//                .font(.system(size: 28, weight: .bold))
//                .foregroundColor(.primary)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white.opacity(0.8))
//                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
//        )
//    }
//}
//
//// Helper view for insight rows
//struct InsightRow: View {
//    var iconName: String
//    var color: Color
//    var text: String
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: iconName)
//                .foregroundColor(color)
//                .frame(width: 24, height: 24)
//
//            Text(text)
//                .font(.subheadline)
//                .foregroundColor(.primary)
//                .fixedSize(horizontal: false, vertical: true)
//        }
//    }
//}
//
//// Helper view for percentage change
//struct PercentageChangeView: View {
//    var currentValue: Int
//    var previousValue: Int
//    var label: String
//
//    private var percentageChange: Double {
//        guard previousValue > 0 else { return 0 }
//        return Double(currentValue - previousValue) / Double(previousValue) * 100
//    }
//
//    private var isPositive: Bool {
//        return percentageChange >= 0
//    }
//
//    var body: some View {
//        HStack(spacing: 4) {
//            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
//                .font(.caption)
//                .foregroundColor(isPositive ? .green : .red)
//
//            Text("\(abs(percentageChange), specifier: "%.1f")%")
//                .font(.caption)
//                .foregroundColor(isPositive ? .green : .red)
//
//            Text(label)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//// Animated progress bar for visual metrics
//struct AnimatedProgressBar: View {
//    var value: Double
//    var maxValue: Double
//    var color: Color
//    @State private var width: Double = 0
//
//    private var percentage: Double {
//        return min(value / maxValue, 1.0)
//    }
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//            Rectangle()
//                .fill(color.opacity(0.2))
//                .frame(height: 8)
//                .cornerRadius(4)
//
//            Rectangle()
//                .fill(color)
//                .frame(width: width, height: 8)
//                .cornerRadius(4)
//        }
//        .onAppear {
//            withAnimation(.easeInOut(duration: 1.0)) {
//                width = percentage * UIScreen.main.bounds.width * 0.8
//            }
//        }
//    }
//}
//
//// Weekly trend view for compact display
//struct WeeklyTrendView: View {
//    var data: [RemoteMemoryData]
//
//    var body: some View {
//        HStack(spacing: 4) {
//            ForEach(data.prefix(7).filter { $0.day != "Summary" }, id: \.day) { day in
//                let total = day.correctAnswers + day.incorrectAnswers
//                let percentage = total > 0 ? Double(day.correctAnswers) / Double(total) : 0
//
//                VStack(spacing: 2) {
//                    Text(day.day)
//                        .font(.system(size: 10))
//                        .foregroundColor(.secondary)
//
//                    Rectangle()
//                        .fill(
//                            LinearGradient(
//                                colors: [
//                                    Color.customLightPurple.opacity(0.7),
//                                    Color.customLightPurple,
//                                ],
//                                startPoint: .bottom,
//                                endPoint: .top
//                            )
//                        )
//                        .frame(width: 20, height: max(percentage * 60, 4))
//                        .cornerRadius(2)
//                }
//            }
//        }
//        .frame(height: 70)
//        .padding(.vertical, 8)
//    }
//}
//
//// Empty state view
//struct EmptyStateView: View {
//    var message: String
//    var iconName: String
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Image(systemName: iconName)
//                .font(.system(size: 48))
//                .foregroundColor(.secondary.opacity(0.6))
//
//            Text(message)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .padding(32)
//        .frame(maxWidth: .infinity)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white.opacity(0.8))
//                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
//        )
//    }
//}
//
//// Helpful utility functions
//extension RemoteReportDetailViewController {
//    func getPerformanceTrend() -> String {
//        let regularData = remoteMemoryData.filter { $0.day != "Summary" }
//        guard regularData.count >= 2 else { return "Insufficient data" }
//
//        let firstHalf = Array(regularData.prefix(regularData.count / 2))
//        let secondHalf = Array(regularData.suffix(regularData.count / 2))
//
//        let firstHalfCorrect = firstHalf.reduce(0) { $0 + $1.correctAnswers }
//        let secondHalfCorrect = secondHalf.reduce(0) { $0 + $1.correctAnswers }
//
//        if secondHalfCorrect > firstHalfCorrect {
//            return "Improving"
//        } else if secondHalfCorrect < firstHalfCorrect {
//            return "Declining"
//        } else {
//            return "Stable"
//        }
//    }
//
//    func getColorForTrend() -> Color {
//        let trend = getPerformanceTrend()
//        switch trend {
//        case "Improving":
//            return .green
//        case "Declining":
//            return .red
//        default:
//            return .blue
//        }
//    }
//}
//
//// Tag view for categorization
//struct TagView: View {
//    var text: String
//    var color: Color
//
//    var body: some View {
//        Text(text)
//            .font(.caption)
//            .foregroundColor(.white)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(color)
//            .cornerRadius(12)
//    }
//}

import Charts
import SwiftUI

struct LineChartView: View {
    let data: [RemoteMemoryData]
    @State private var showChartData = false

    var body: some View {
        VStack {
            Chart {
                ForEach(data) { report in
                    if report.day != "Summary" {
                        LineMark(
                            x: .value("Day", report.day),
                            y: .value("Correct Answers", showChartData ? report.correctAnswers : 0)
                        )
                        .foregroundStyle(Color(AppColors.successColor).gradient)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .symbol {
                            Circle()
                                .fill(Color(AppColors.successColor))
                                .frame(width: 8, height: 8)
                        }
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Day", report.day),
                            y: .value("Incorrect Answers", showChartData ? report.incorrectAnswers : 0)
                        )
                        .foregroundStyle(Color(AppColors.errorColor).gradient)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        .symbol {
                            Circle()
                                .fill(Color(AppColors.errorColor))
                                .frame(width: 8, height: 8)
                        }
                        .interpolationMethod(.catmullRom)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel()
                        .font(Font(Constants.FontandColors.descriptionFont))
                        .foregroundStyle(Color(AppColors.secondaryTextColor))

                    AxisGridLine()
                        .foregroundStyle(Color(AppColors.secondaryTextColor).opacity(0.2))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(Font(Constants.FontandColors.descriptionFont))
                        .foregroundStyle(Color(AppColors.secondaryTextColor))
                }
            }
            .chartForegroundStyleScale([
                "Correct Answers": Color(AppColors.successColor).gradient,
                "Incorrect Answers": Color(AppColors.errorColor).gradient,
            ])
            .chartLegend(position: .bottom, alignment: .center, spacing: 20)
            .chartLegend(.visible)
            .animation(.easeInOut(duration: 1.0), value: showChartData)
            .frame(height: 250)
            .padding(.all, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showChartData = true
                }
            }
        }
    }
}

struct RemoteReportDetailViewController: View {
    let verifiedUserDocID: String
    @State private var remoteMemoryData: [RemoteMemoryData] = []
    @State private var isLoading = true
    @State private var selectedTimeframe = "Month"
    private let timeframeOptions = ["Week", "Month", "Quarter"]

    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    var body: some View {
        ZStack {
            Color(AppColors.cardBackgroundColor)
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        ForEach(timeframeOptions, id: \.self) { option in
                            Button(action: {
                                withAnimation {
                                    selectedTimeframe = option
                                }
                            }) {
                                Text(option)
                                    .font(Font(Constants.FontandColors.subtitleFont))
                                    .fontWeight(selectedTimeframe == option ? .semibold : .regular)
                                    .foregroundColor(selectedTimeframe == option ? Color(AppColors.inverseTextColor) : Color(AppColors.primaryTextColor))
                                    .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
                                    .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                                    .background(
                                        RoundedRectangle(cornerRadius: CGFloat(Constants.ButtonStyle.DefaultButtonCornerRadius))
                                            .fill(selectedTimeframe == option ?
                                                  Color(AppColors.primaryButtonColor) :
                                                  Color(AppColors.secondaryButtonColor))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))

                    if let summary = remoteMemoryData.first(where: { $0.day == "Summary" }) {
                        HStack(spacing: 16) {
                            SummaryCard(
                                title: "Correct",
                                value: "\(summary.correctAnswers)",
                                iconName: "checkmark.circle.fill",
                                color: Color(AppColors.successColor)
                            )

                            SummaryCard(
                                title: "Incorrect",
                                value: "\(summary.incorrectAnswers)",
                                iconName: "xmark.circle.fill",
                                color: Color(AppColors.errorColor)
                            )
                        }
                        .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Memory Performance Trend")
                            .font(Font(Constants.FontandColors.titleFont))
                            .foregroundColor(Color(AppColors.primaryTextColor))
                            .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))

                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .padding()
                                Spacer()
                            }
                            .frame(height: 250)
                        } else if remoteMemoryData.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 16) {
                                    Image(systemName: "chart.line.downtrend.xyaxis")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(AppColors.secondaryTextColor).opacity(0.6))

                                    Text("No data available for this timeframe")
                                        .font(Font(Constants.FontandColors.descriptionFont))
                                        .foregroundColor(Color(AppColors.secondaryTextColor))
                                }
                                .padding()
                                Spacer()
                            }
                            .frame(height: 250)
                        } else {
                            LineChartView(data: remoteMemoryData)
                        }
                    }
                    .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                            .fill(Color(AppColors.cardBackgroundColor))
                            .shadow(
                                color: Color(cgColor: Constants.FontandColors.defaultshadowColor).opacity(Constants.FontandColors.defaultshadowOpacity),
                                radius: Constants.FontandColors.defaultshadowRadius,
                                x: Constants.FontandColors.defaultshadowOffset.width,
                                y: Constants.FontandColors.defaultshadowOffset.height
                            )
                    )
                    .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))

                    if let summary = remoteMemoryData.first(where: { $0.day == "Summary" }) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "sparkles.rectangle.stack")
                                    .font(.title2)
                                    .foregroundColor(Color(AppColors.iconColor))

                                Text("Performance Insights")
                                    .font(Font(Constants.FontandColors.titleFont))
                                    .foregroundColor(Color(AppColors.primaryTextColor))
                            }

                            VStack(alignment: .leading, spacing: 10) {
                                InsightRow(
                                    iconName: "arrow.up.right",
                                    color: Color(AppColors.successColor),
                                    text: "Your highest performance was on day \(getBestPerformanceDay()) with \(getHighestCorrectAnswers()) correct answers."
                                )

                                Divider()

                                InsightRow(
                                    iconName: "chart.line.uptrend.xyaxis",
                                    color: Color(AppColors.iconColor),
                                    text: "Overall accuracy rate: \(calculateAccuracyRate())%"
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                                    .fill(Color(AppColors.cardBackgroundColor).opacity(0.8))
                            )
                        }
                        .padding(CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                        .background(
                            RoundedRectangle(cornerRadius: CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                                .fill(Color(AppColors.cardBackgroundColor))
                                .shadow(
                                    color: Color(cgColor: Constants.FontandColors.defaultshadowColor).opacity(Constants.FontandColors.defaultshadowOpacity),
                                    radius: Constants.FontandColors.defaultshadowRadius,
                                    x: Constants.FontandColors.defaultshadowOffset.width,
                                    y: Constants.FontandColors.defaultshadowOffset.height
                                )
                        )
                        .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(Color(AppColors.iconColor))

                            Text("About Remote Insights")
                                .font(Font(Constants.FontandColors.titleFont))
                                .foregroundColor(Color(AppColors.primaryTextColor))
                        }

                        Text("Remote memory refers to your ability to recall events or information from the distant past, typically over a week or more.")
                            .font(Font(Constants.FontandColors.descriptionFont))
                            .foregroundColor(Color(AppColors.secondaryTextColor))

                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "chart.xyaxis.line")
                                .foregroundColor(Color(AppColors.iconColor))
                                .frame(width: 24, height: 24)

                            Text("By tracking your performance over time, we can observe trends that help you and your caregivers understand how well your long-term memory is functioning.")
                                .font(Font(Constants.FontandColors.descriptionFont))
                                .foregroundColor(Color(AppColors.secondaryTextColor))
                        }
                    }
                    .padding(CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                    .background(
                        RoundedRectangle(cornerRadius: CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                            .fill(Color(AppColors.cardBackgroundColor))
                            .shadow(
                                color: Color(cgColor: Constants.FontandColors.defaultshadowColor).opacity(Constants.FontandColors.defaultshadowOpacity),
                                radius: Constants.FontandColors.defaultshadowRadius,
                                x: Constants.FontandColors.defaultshadowOffset.width,
                                y: Constants.FontandColors.defaultshadowOffset.height
                            )
                    )
                    .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Remote Memory")
        }
        .onAppear {
            print("🟢 RemoteReportDetailViewController appeared. Fetching data...")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                fetchRemoteMemoryData(for: verifiedUserDocID, month: currentMonth) { data in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        if data.isEmpty {
                            print("⚠️ No data found, setting default values.")
                            self.remoteMemoryData = [RemoteMemoryData(day: "01", correctAnswers: 0, incorrectAnswers: 0)]
                        } else {
                            self.remoteMemoryData = data
                        }
                        print("📊 Final Remote Memory Data: \(self.remoteMemoryData)")
                    }
                }
            }
        }
    }

    private func getBestPerformanceDay() -> String {
        let dataPoints = remoteMemoryData.filter { $0.day != "Summary" }
        if let bestDay = dataPoints.max(by: { $0.correctAnswers < $1.correctAnswers }) {
            return bestDay.day
        }
        return "N/A"
    }

    private func getHighestCorrectAnswers() -> Int {
        let dataPoints = remoteMemoryData.filter { $0.day != "Summary" }
        if let bestDay = dataPoints.max(by: { $0.correctAnswers < $1.correctAnswers }) {
            return bestDay.correctAnswers
        }
        return 0
    }

    private func calculateAccuracyRate() -> String {
        if let summary = remoteMemoryData.first(where: { $0.day == "Summary" }) {
            let total = summary.correctAnswers + summary.incorrectAnswers
            if total > 0 {
                let accuracy = Double(summary.correctAnswers) / Double(total) * 100
                return String(format: "%.1f", accuracy)
            }
        }
        return "0.0"
    }
}

struct SummaryCard: View {
    var title: String
    var value: String
    var iconName: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .semibold))

                Text(title)
                    .font(Font(Constants.FontandColors.subtitleFont))
                    .foregroundColor(Color(AppColors.secondaryTextColor))
            }

            Text(value)
                .font(Font(Constants.FontandColors.titleFont))
                .foregroundColor(Color(AppColors.primaryTextColor))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
        .background(
            RoundedRectangle(cornerRadius: CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                .fill(Color(AppColors.cardBackgroundColor))
                .shadow(
                    color: color.opacity(0.1),
                    radius: Constants.FontandColors.defaultshadowRadius,
                    x: Constants.FontandColors.defaultshadowOffset.width,
                    y: Constants.FontandColors.defaultshadowOffset.height
                )
        )
    }
}

struct InsightRow: View {
    var iconName: String
    var color: Color
    var text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(color)
                .frame(width: 24, height: 24)

            Text(text)
                .font(Font(Constants.FontandColors.descriptionFont))
                .foregroundColor(Color(AppColors.secondaryTextColor))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct PercentageChangeView: View {
    var currentValue: Int
    var previousValue: Int
    var label: String

    private var percentageChange: Double {
        guard previousValue > 0 else { return 0 }
        return Double(currentValue - previousValue) / Double(previousValue) * 100
    }

    private var isPositive: Bool {
        return percentageChange >= 0
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                .font(.caption)
                .foregroundColor(isPositive ? Color(AppColors.successColor) : Color(AppColors.errorColor))

            Text("\(abs(percentageChange), specifier: "%.1f")%")
                .font(Font(Constants.FontandColors.descriptionFont))
                .foregroundColor(isPositive ? Color(AppColors.successColor) : Color(AppColors.errorColor))

            Text(label)
                .font(Font(Constants.FontandColors.descriptionFont))
                .foregroundColor(Color(AppColors.secondaryTextColor))
        }
    }
}

struct AnimatedProgressBar: View {
    var value: Double
    var maxValue: Double
    var color: Color
    @State private var width: Double = 0

    private var percentage: Double {
        return min(value / maxValue, 1.0)
    }

    var body: some View {
        ZStack(alignment: .leading) {
        Rectangle()
            .fill(color.opacity(0.2))
            .frame(height: 8)
            .cornerRadius(CGFloat(Constants.CardSize.DefaultCardCornerRadius))

        Rectangle()
            .fill(color)
            .frame(width: width, height: 8)
            .cornerRadius(CGFloat(Constants.CardSize.DefaultCardCornerRadius))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                width = percentage * UIScreen.main.bounds.width * 0.8
            }
        }
    }
}

struct WeeklyTrendView: View {
    var data: [RemoteMemoryData]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(data.prefix(7).filter { $0.day != "Summary" }, id: \.day) { day in
                let total = day.correctAnswers + day.incorrectAnswers
                let percentage = total > 0 ? Double(day.correctAnswers) / Double(total) : 0

                VStack(spacing: 2) {
                    Text(day.day)
                        .font(Font(Constants.FontandColors.descriptionFont))
                        .foregroundColor(Color(AppColors.secondaryTextColor))

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(AppColors.successColor).opacity(0.7),
                                    Color(AppColors.successColor),
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 20, height: max(percentage * 60, 4))
                        .cornerRadius(CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                }
            }
        }
        .frame(height: 70)
        .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
    }
}

struct EmptyStateView: View {
    var message: String
    var iconName: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundColor(Color(AppColors.secondaryTextColor).opacity(0.6))

            Text(message)
                .font(Font(Constants.FontandColors.descriptionFont))
                .foregroundColor(Color(AppColors.secondaryTextColor))
                .multilineTextAlignment(.center)
        }
        .padding(CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                .fill(Color(AppColors.cardBackgroundColor))
                .shadow(
                    color: Color(cgColor: Constants.FontandColors.defaultshadowColor).opacity(Constants.FontandColors.defaultshadowOpacity),
                    radius: Constants.FontandColors.defaultshadowRadius,
                    x: Constants.FontandColors.defaultshadowOffset.width,
                    y: Constants.FontandColors.defaultshadowOffset.height
                )
        )
    }
}

extension RemoteReportDetailViewController {
    func getPerformanceTrend() -> String {
        let regularData = remoteMemoryData.filter { $0.day != "Summary" }
        guard regularData.count >= 2 else { return "Insufficient data" }

        let firstHalf = Array(regularData.prefix(regularData.count / 2))
        let secondHalf = Array(regularData.suffix(regularData.count / 2))

        let firstHalfCorrect = firstHalf.reduce(0) { $0 + $1.correctAnswers }
        let secondHalfCorrect = secondHalf.reduce(0) { $0 + $1.correctAnswers }

        if secondHalfCorrect > firstHalfCorrect {
            return "Improving"
        } else if secondHalfCorrect < firstHalfCorrect {
            return "Declining"
        } else {
            return "Stable"
        }
    }

    func getColorForTrend() -> Color {
        let trend = getPerformanceTrend()
        switch trend {
        case "Improving":
            return Color(AppColors.successColor)
        case "Declining":
            return Color(AppColors.errorColor)
        default:
            return Color(AppColors.iconColor)
        }
    }
}

struct TagView: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
        .font(Font(Constants.FontandColors.descriptionFont))
        .foregroundColor(Color(AppColors.inverseTextColor))
        .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
        .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
        .background(color)
        .cornerRadius(CGFloat(Constants.CardSize.DefaultCardCornerRadius))
    }
}
