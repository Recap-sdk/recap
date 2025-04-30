////
////  RecentMemoryChart.swift
////  recap_charts
////
////  Created by admin70 on 13/11/24.
////
//
//import SwiftUI
//import Charts
//
//struct BarChartView: View {
//    var data: [RecentMemoryData]
//    
//    var body: some View {
//        Chart {
//            ForEach(data) { dayData in
//                let shortDay = String(dayData.day.prefix(3))
//                let total = dayData.correctAnswers + dayData.incorrectAnswers
//                
//                BarMark(
//                    x: .value("Day", shortDay),
//                    y: .value("Correct", dayData.correctAnswers)
//                )
//                .foregroundStyle(Color.customLightPurple.gradient)
//                .cornerRadius(6)
//                
//                BarMark(
//                    x: .value("Day", shortDay),
//                    y: .value("Incorrect", dayData.incorrectAnswers)
//                )
//                .foregroundStyle(Color.customLightRed.gradient)
//                .cornerRadius(6)
//            }
//        }
//        .chartYAxis {
//            AxisMarks(position: .leading, values: .stride(by: 5)) { value in
//                AxisValueLabel()
//                    .font(.caption)
//                    .foregroundStyle(Color.secondary)
//                
//                AxisGridLine()
//                    .foregroundStyle(Color.secondary.opacity(0.2))
//            }
//        }
//        .chartXAxis {
//            AxisMarks { value in
//                AxisValueLabel()
//                    .font(.caption)
//                    .foregroundStyle(Color.secondary)
//            }
//        }
//        .chartForegroundStyleScale([
//            "Correct": Color.customLightPurple.gradient,
//            "Incorrect": Color.customLightRed.gradient
//        ])
//        .chartLegend(position: .bottom, alignment: .center, spacing: 20)
//        .chartLegend(.visible)
//        .frame(height: 250)
//        .padding()
//    }
//}
//
//struct RecentReportDetailViewController: View {
//    let verifiedUserDocID: String
//    @StateObject private var recentMemoryDataModel = RecentMemoryDataModel()
//    @Environment(\.colorScheme) var colorScheme
//    @State private var animateChart = false
//
//    var body: some View {
//        ZStack {
//            // Modern gradient background with subtle animation
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.95, green: 0.97, blue: 0.99),
//                    Color(red: 0.99, green: 0.95, blue: 0.97)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//            
//            ScrollView {
//                VStack(spacing: 24) {
//                    
//                    // Summary card
//                    HStack(spacing: 16) {
//                        SummaryCard_recent(
//                            title: "Correct",
//                            value: String(recentMemoryDataModel.recentMemoryData.reduce(0) { $0 + $1.correctAnswers }),
//                            iconName: "checkmark.circle.fill",
//                            color: .customLightPurple
//                        )
//                        
//                        SummaryCard_recent(
//                            title: "Incorrect",
//                            value: String(recentMemoryDataModel.recentMemoryData.reduce(0) { $0 + $1.incorrectAnswers }),
//                            iconName: "xmark.circle.fill",
//                            color: .customLightRed
//                        )
//                    }
//                    .padding(.horizontal)
//
//                    // Week Navigation with improved UI
//                    HStack {
//                        Button(action: {
//                            withAnimation {
//                                recentMemoryDataModel.goToPreviousWeek(for: verifiedUserDocID, selectedMonth: getCurrentMonth())
//                                animateChart = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    withAnimation(.easeInOut(duration: 0.5)) {
//                                        animateChart = true
//                                    }
//                                }
//                            }
//                        }) {
//                            Label("Previous", systemImage: "chevron.left")
//                                .font(.subheadline)
//                                .foregroundColor(recentMemoryDataModel.selectedWeekIndex > 0 ? .primary : .secondary)
//                                .padding(.vertical, 8)
//                                .padding(.horizontal, 16)
//                                .background(recentMemoryDataModel.selectedWeekIndex > 0 ? Color.primary.opacity(0.1) : Color.secondary.opacity(0.05))
//                                .cornerRadius(8)
//                        }
//                        .disabled(recentMemoryDataModel.selectedWeekIndex == 0)
//
//                        Spacer()
//                        
//                        Text("Week \(recentMemoryDataModel.selectedWeekIndex + 1)")
//                            .font(.headline)
//                            .padding(.horizontal)
//                            .padding(.vertical, 8)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(Color.primary.opacity(0.05))
//                            )
//
//                        Spacer()
//                        
//                        Button(action: {
//                            withAnimation {
//                                recentMemoryDataModel.goToNextWeek(for: verifiedUserDocID, selectedMonth: getCurrentMonth())
//                                animateChart = false
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    withAnimation(.easeInOut(duration: 0.5)) {
//                                        animateChart = true
//                                    }
//                                }
//                            }
//                        }) {
//                            Label("Next", systemImage: "chevron.right")
//                                .font(.subheadline)
//                                .foregroundColor(recentMemoryDataModel.selectedWeekIndex < recentMemoryDataModel.availableWeeks.count - 1 ? .primary : .secondary)
//                                .padding(.vertical, 8)
//                                .padding(.horizontal, 16)
//                                .background(recentMemoryDataModel.selectedWeekIndex < recentMemoryDataModel.availableWeeks.count - 1 ? Color.primary.opacity(0.1) : Color.secondary.opacity(0.05))
//                                .cornerRadius(8)
//                        }
//                        .disabled(recentMemoryDataModel.selectedWeekIndex == recentMemoryDataModel.availableWeeks.count - 1)
//                    }
//                    .padding(.horizontal)
//
//                    // Bar Chart Section with enhanced styling
//                    VStack(alignment: .leading, spacing: 16) {
//                        Text("Daily Performance")
//                            .font(.headline)
//                            .padding(.horizontal)
//                        
//                        if animateChart {
//                            BarChartView(data: recentMemoryDataModel.recentMemoryData)
//                                .transition(.opacity)
//                        } else {
//                            BarChartView(data: recentMemoryDataModel.recentMemoryData)
//                                .opacity(0)
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
//                    // About Insights Section with modern card design
//                    VStack(alignment: .leading, spacing: 16) {
//                        HStack {
//                            Image(systemName: "brain.head.profile")
//                                .font(.title2)
//                                .foregroundColor(.purple)
//                            
//                            Text("About Recent Insights")
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                        }
//                        
//                        Text("""
//                        Your recent memory insights analyze your ability to recall information from the last week. This section evaluates how well you retain details from recent interactions, helping to monitor your short-term memory.
//                        """)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        
//                        HStack(alignment: .top, spacing: 12) {
//                            Image(systemName: "sparkles")
//                                .foregroundColor(.blue)
//                                .frame(width: 24, height: 24)
//                            
//                            Text("A strong performance in this area indicates healthy short-term recall. Identifying trends can provide insights into cognitive health over time.")
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
//        }
//        .onAppear {
//            let currentMonth = getCurrentMonth()
//            recentMemoryDataModel.fetchWeeks(for: verifiedUserDocID, selectedMonth: currentMonth)
//            
//            // Animate chart on appear
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                withAnimation(.easeInOut(duration: 0.8)) {
//                    animateChart = true
//                }
//            }
//        }
//        .navigationTitle("Recent Memory")
//    }
//
//    private func getCurrentMonth() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//        return formatter.string(from: Date())
//    }
//}
//
//// Helper view for summary cards
//struct SummaryCard_recent: View {
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



import SwiftUI
import Charts

struct BarChartView: View {
    var data: [RecentMemoryData]
    
    var body: some View {
        Chart {
            ForEach(data) { dayData in
                let shortDay = String(dayData.day.prefix(3))
                let total = dayData.correctAnswers + dayData.incorrectAnswers
                
                BarMark(
                    x: .value("Day", shortDay),
                    y: .value("Correct", dayData.correctAnswers)
                )
                .foregroundStyle(Color(AppColors.iconColor).opacity(0.8))
                .cornerRadius(CGFloat(Constants.CardSize.DefaultCardCornerRadius))
                
                BarMark(
                    x: .value("Day", shortDay),
                    y: .value("Incorrect", dayData.incorrectAnswers)
                )
                .foregroundStyle(Color(AppColors.errorColor).gradient)
                .cornerRadius(CGFloat(Constants.CardSize.DefaultCardCornerRadius))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 5)) { value in
                AxisValueLabel()
                    .font(Font(Constants.FontandColors.descriptionFont))
                    .foregroundStyle(Color(AppColors.secondaryTextColor))
                
                AxisGridLine()
                    .foregroundStyle(Color(AppColors.secondaryTextColor).opacity(0.2))
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(Font(Constants.FontandColors.descriptionFont))
                    .foregroundStyle(Color(AppColors.secondaryTextColor))
            }
        }
        .chartForegroundStyleScale([
            "Correct": Color(AppColors.iconColor).gradient,
            "Incorrect": Color(AppColors.errorColor).gradient
        ])
        .chartLegend(position: .bottom, alignment: .center, spacing: 20)
        .chartLegend(.visible)
        .frame(height: 250)
        .padding(.all, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
    }
}

struct RecentReportDetailViewController: View {
    let verifiedUserDocID: String
    @StateObject private var recentMemoryDataModel = RecentMemoryDataModel()
    @Environment(\.colorScheme) var colorScheme
    @State private var animateChart = false

    var body: some View {
        ZStack {
            Color(AppColors.cardBackgroundColor)
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        SummaryCard_recent(
                            title: "Correct",
                            value: String(recentMemoryDataModel.recentMemoryData.reduce(0) { $0 + $1.correctAnswers }),
                            iconName: "checkmark.circle.fill",
                            color: Color(AppColors.successColor)
                        )
                        
                        SummaryCard_recent(
                            title: "Incorrect",
                            value: String(recentMemoryDataModel.recentMemoryData.reduce(0) { $0 + $1.incorrectAnswers }),
                            iconName: "xmark.circle.fill",
                            color: Color(AppColors.errorColor)
                        )
                    }
                    .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))

                    HStack {
                        Button(action: {
                            withAnimation {
                                recentMemoryDataModel.goToPreviousWeek(for: verifiedUserDocID, selectedMonth: getCurrentMonth())
                                animateChart = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        animateChart = true
                                    }
                                }
                            }
                        }) {
                            Label("Previous", systemImage: "chevron.left")
                                .font(Font(Constants.FontandColors.subtitleFont))
                                .foregroundColor(recentMemoryDataModel.selectedWeekIndex > 0 ? Color(AppColors.primaryTextColor) : Color(AppColors.secondaryTextColor))
                                .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
                                .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                                .background(
                                    recentMemoryDataModel.selectedWeekIndex > 0 ?
                                        Color(AppColors.secondaryButtonColor) :
                                        Color(AppColors.secondaryTextColor).opacity(0.05)
                                )
                                .cornerRadius(CGFloat(Constants.ButtonStyle.DefaultButtonCornerRadius))
                        }
                        .disabled(recentMemoryDataModel.selectedWeekIndex == 0)

                        Spacer()
                        
                        Text("Week \(recentMemoryDataModel.selectedWeekIndex + 1)")
                            .font(Font(Constants.FontandColors.titleFont))
                            .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                            .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
                            .background(
                                RoundedRectangle(cornerRadius: CGFloat(Constants.ButtonStyle.DefaultButtonCornerRadius))
                                    .fill(Color(AppColors.cardBackgroundColor))
                            )

                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                recentMemoryDataModel.goToNextWeek(for: verifiedUserDocID, selectedMonth: getCurrentMonth())
                                animateChart = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        animateChart = true
                                    }
                                }
                            }
                        }) {
                            Label("Next", systemImage: "chevron.right")
                                .font(Font(Constants.FontandColors.subtitleFont))
                                .foregroundColor(recentMemoryDataModel.selectedWeekIndex < recentMemoryDataModel.availableWeeks.count - 1 ? Color(AppColors.primaryTextColor) : Color(AppColors.secondaryTextColor))
                                .padding(.vertical, CGFloat(Constants.paddingKeys.DefaultPaddingTop))
                                .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                                .background(
                                    recentMemoryDataModel.selectedWeekIndex < recentMemoryDataModel.availableWeeks.count - 1 ?
                                        Color(AppColors.secondaryButtonColor) :
                                        Color(AppColors.secondaryTextColor).opacity(0.05)
                                )
                                .cornerRadius(CGFloat(Constants.ButtonStyle.DefaultButtonCornerRadius))
                        }
                        .disabled(recentMemoryDataModel.selectedWeekIndex == recentMemoryDataModel.availableWeeks.count - 1)
                    }
                    .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Daily Performance")
                            .font(Font(Constants.FontandColors.titleFont))
                            .foregroundColor(Color(AppColors.primaryTextColor))
                            .padding(.horizontal, CGFloat(Constants.paddingKeys.DefaultPaddingLeft))
                        
                        if animateChart {
                            BarChartView(data: recentMemoryDataModel.recentMemoryData)
                                .transition(.opacity)
                        } else {
                            BarChartView(data: recentMemoryDataModel.recentMemoryData)
                                .opacity(0)
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

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                                .foregroundColor(Color(AppColors.iconColor))
                            
                            Text("About Recent Insights")
                                .font(Font(Constants.FontandColors.titleFont))
                                .foregroundColor(Color(AppColors.primaryTextColor))
                        }
                        
                        Text("""
                        Your recent memory insights analyze your ability to recall information from the last week. This section evaluates how well you retain details from recent interactions, helping to monitor your short-term memory.
                        """)
                        .font(Font(Constants.FontandColors.descriptionFont))
                        .foregroundColor(Color(AppColors.secondaryTextColor))
                        
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(AppColors.highlightColor))
                                .frame(width: 24, height: 24)
                            
                            Text("A strong performance in this area indicates healthy short-term recall. Identifying trends can provide insights into cognitive health over time.")
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
        }
        .onAppear {
            let currentMonth = getCurrentMonth()
            recentMemoryDataModel.fetchWeeks(for: verifiedUserDocID, selectedMonth: currentMonth)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateChart = true
                }
            }
        }
        .navigationTitle("Recent Memory")
    }

    private func getCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}

struct SummaryCard_recent: View {
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
