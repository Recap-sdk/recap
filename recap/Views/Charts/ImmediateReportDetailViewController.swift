//
//  immediateMemoryChart.swift
//  recap_charts
//
//  Created by admin70 on 13/11/24.
//

//import SwiftUI
//import Charts
//
//struct ImmediateReportDetailViewController: View {
//    @State private var immediateMemoryData: [ImmediateMemoryData] = []
//    @State private var selectedDate: Date? = nil
//    private let verifiedUserDocID: String
//    
//    init(verifiedUserDocID: String) {
//        self.verifiedUserDocID = verifiedUserDocID
//    }
//
//    var body: some View {
//        ZStack {
//            // Modern gradient background that's softer and more subtle
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(.systemBackground),
//                    Color(.systemGray6)
//                ]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Data summary card
//                    summaryCard
//                    
//                    // Date selector and chart
//                    if !immediateMemoryData.isEmpty {
//                        dateSelector
//                        memoryChartCard
//                    } else {
//                        emptyStateView
//                    }
//                    
//                    // Information section
//                    informationCard
//                }
//                .padding()
//            }
//        }
//        .navigationTitle("Immediate Memory")
//        .onAppear {
//            loadMemoryData()
//        }
//    }
//    
//    // MARK: - Components
//    
//    var summaryCard: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack {
//                VStack(alignment: .leading) {
//                    Text("Overall Performance")
//                        .font(.headline)
//                        .foregroundColor(.primary)
//                    
//                    Text(calculateOverallScore())
//                        .font(.system(size: 36, weight: .bold, design: .rounded))
//                        .foregroundColor(scoreColor())
//                }
//                
//                Spacer()
//                
//                Image(systemName: "brain.fill")
//                    .font(.system(size: 32))
//                    .foregroundColor(scoreColor().opacity(0.8))
//                    .frame(width: 60, height: 60)
//                    .background(
//                        Circle()
//                            .fill(scoreColor().opacity(0.1))
//                    )
//            }
//            
//            if !immediateMemoryData.isEmpty {
//                Text("Based on \(getTotalAnswers()) questions over \(immediateMemoryData.count) sessions")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//        )
//    }
//    
//    var dateSelector: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                ForEach(immediateMemoryData) { data in
//                    Button(action: {
//                        withAnimation(.spring()) {
//                            selectedDate = data.date
//                        }
//                    }) {
//                        Text(data.date.formatted(.dateTime.day().month(.abbreviated)))
//                            .font(.system(.subheadline, design: .rounded))
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(
//                                Capsule()
//                                    .fill(isDateSelected(data.date) ?
//                                          Color.accentColor : Color(.systemGray6))
//                            )
//                            .foregroundColor(isDateSelected(data.date) ?
//                                            .white : .primary)
//                    }
//                }
//            }
//            .padding(.horizontal, 4)
//        }
//    }
//
//    // Helper function to check if a date is selected
//    private func isDateSelected(_ date: Date) -> Bool {
//        if let selectedDate = selectedDate {
//            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
//        }
//        return false
//    }
//    
//    var memoryChartCard: some View {
//        let displayData = selectedDate == nil ?
//            immediateMemoryData :
//            immediateMemoryData.filter { $0.date == selectedDate }
//        
//        return VStack(alignment: .leading, spacing: 16) {
//            if !displayData.isEmpty {
//                ForEach(displayData) { data in
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text(data.date.formatted(.dateTime.weekday(.wide).day().month().year()))
//                            .font(.headline)
//                            .foregroundColor(.primary)
//                        
//                        HStack(alignment: .center) {
//                            // Modern donut chart
//                            ModernDonutChartView(
//                                correctAnswers: data.correctAnswers,
//                                incorrectAnswers: data.incorrectAnswers
//                            )
//                            .frame(width: 160, height: 160)
//                            
//                            VStack(alignment: .leading, spacing: 16) {
//                                StatItemView(
//                                    title: "Correct",
//                                    value: "\(data.correctAnswers)",
//                                    color: Color.green
//                                )
//                                
//                                StatItemView(
//                                    title: "Incorrect",
//                                    value: "\(data.incorrectAnswers)",
//                                    color: Color.red
//                                )
//                                
//                                if data.correctAnswers + data.incorrectAnswers > 0 {
//                                    StatItemView(
//                                        title: "Accuracy",
//                                        value: "\(Int(Double(data.correctAnswers) / Double(data.correctAnswers + data.incorrectAnswers) * 100))%",
//                                        color: Color.blue
//                                    )
//                                }
//                            }
//                            .padding(.leading, 8)
//                        }
//                    }
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 16)
//                            .fill(Color(.systemBackground))
//                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//                    )
//                }
//            }
//        }
//    }
//    
//    var emptyStateView: some View {
//        VStack(spacing: 16) {
//            Image(systemName: "brain.head.profile")
//                .font(.system(size: 56))
//                .foregroundColor(.secondary.opacity(0.6))
//                .padding(.bottom, 8)
//            
//            Text("No Memory Data Available")
//                .font(.headline)
//                .foregroundColor(.primary)
//            
//            Text("Complete memory exercises to see your results here")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 40)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//        )
//    }
//    
//    var informationCard: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("About Immediate Memory")
//                .font(.headline)
//                .foregroundColor(.primary)
//            
//            VStack(alignment: .leading, spacing: 12) {
//                insightRow(
//                    icon: "timer",
//                    title: "Rapid Recall",
//                    description: "Your ability to remember information learned minutes ago"
//                )
//                
//                Divider()
//                
//                insightRow(
//                    icon: "brain.head.profile",
//                    title: "Working Memory",
//                    description: "Essential for problem-solving and everyday tasks"
//                )
//                
//                Divider()
//                
//                insightRow(
//                    icon: "arrow.up.forward",
//                    title: "Improvement Tips",
//                    description: "Practice attention to detail and focus during learning"
//                )
//            }
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color(.systemGray6))
//            )
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
//        )
//    }
//    
//    func insightRow(icon: String, title: String, description: String) -> some View {
//        HStack(alignment: .top, spacing: 12) {
//            Image(systemName: icon)
//                .font(.system(size: 18))
//                .foregroundColor(.accentColor)
//                .frame(width: 24, height: 24)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .font(.system(.subheadline, weight: .semibold))
//                    .foregroundColor(.primary)
//                
//                Text(description)
//                    .font(.system(.footnote))
//                    .foregroundColor(.secondary)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//        }
//    }
//    
//    // MARK: - Helper Functions
//    
//    private func loadMemoryData() {
//        fetchImmediateMemoryData(for: verifiedUserDocID) { data in
//            DispatchQueue.main.async {
//                self.immediateMemoryData = data.sorted(by: { $0.date > $1.date })
//                
//                // Set default selected date to today if available, otherwise most recent
//                let today = Date()
//                let todayData = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
//                
//                if let todayData = todayData {
//                    self.selectedDate = todayData.date
//                } else if !data.isEmpty {
//                    self.selectedDate = data.first?.date
//                }
//            }
//        }
//    }
//    
//    private func calculateOverallScore() -> String {
//        let totalCorrect = immediateMemoryData.reduce(0) { $0 + $1.correctAnswers }
//        let totalQuestions = immediateMemoryData.reduce(0) { $0 + $1.correctAnswers + $1.incorrectAnswers }
//        
//        guard totalQuestions > 0 else { return "N/A" }
//        
//        let percentage = Double(totalCorrect) / Double(totalQuestions) * 100
//        return "\(Int(percentage))%"
//    }
//    
//    private func getTotalAnswers() -> Int {
//        immediateMemoryData.reduce(0) { $0 + $1.correctAnswers + $1.incorrectAnswers }
//    }
//    
//    private func scoreColor() -> Color {
//        let score = calculateOverallScore()
//        guard score != "N/A" else { return .gray }
//        
//        let percentage = Int(score.dropLast()) ?? 0
//        
//        switch percentage {
//        case 0..<60: return .red
//        case 60..<75: return .orange
//        case 75..<90: return .blue
//        default: return .green
//        }
//    }
//}
//
//
//// MARK: - Supporting Views
//
//struct ModernDonutChartView: View {
//    let correctAnswers: Int
//    let incorrectAnswers: Int
//    
//    @State private var animationProgress: Double = 0
//    
//    var totalAnswers: Int {
//        correctAnswers + incorrectAnswers
//    }
//    
//    var correctRatio: Double {
//        totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) : 0
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background circle
//            Circle()
//                .stroke(Color(.systemGray5), lineWidth: 12)
//            
//            // Progress circle
//            Circle()
//                .trim(from: 0, to: correctRatio * animationProgress)
//                .stroke(
//                    Color.green,
//                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
//                )
//                .rotationEffect(.degrees(-90))
//                .animation(.easeOut(duration: 1), value: animationProgress)
//            
//            // Inner circle with percentage
//            VStack(spacing: 0) {
//                Text("\(Int(correctRatio * 100 * animationProgress))%")
//                    .font(.system(size: 28, weight: .bold, design: .rounded))
//                    .foregroundColor(.primary)
//                    .animation(.easeOut(duration: 1), value: animationProgress)
//                
//                Text("Correct")
//                    .font(.system(size: 12, weight: .medium))
//                    .foregroundColor(.secondary)
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                withAnimation(.easeOut(duration: 1.0)) {
//                    animationProgress = 1.0
//                }
//            }
//        }
//    }
//}
//struct DonutChartView: View {
//    let correctAnswers: Int
//    let incorrectAnswers: Int
//
//    var body: some View {
//        let totalAnswers = correctAnswers + incorrectAnswers
//        let correctFraction = totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) : 0
//        let incorrectFraction = totalAnswers > 0 ? Double(incorrectAnswers) / Double(totalAnswers) : 0
//
//        ZStack {
//            Circle()
//                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
//
//            if totalAnswers > 0 {
//                Circle()
//                    .trim(from: 0, to: correctFraction)
//                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.customLightPurple]), center: .center), lineWidth: 40)
//                    .rotationEffect(.degrees(-90))
//
//                Circle()
//                    .trim(from: correctFraction, to: correctFraction + incorrectFraction)
//                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.customLightRed]), center: .center), lineWidth: 40)
//                    .rotationEffect(.degrees(-90))
//            } else {
//                Text("No memory data")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//
//            Circle()
//                .fill(Color.white)
//                .frame(width: 180, height: 180)
//
//            VStack {
//                Text(totalAnswers > 0 ? "\(correctAnswers) / \(totalAnswers)" : "No Data")
//                    .font(.headline)
//                if totalAnswers > 0 {
//                    Text("Correct")
//                        .font(.subheadline)
//                }
//            }
//        }
//        .frame(width: 190, height: 190)
//    }
//}
//struct StatItemView: View {
//    let title: String
//    let value: String
//    let color: Color
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            Circle()
//                .fill(color)
//                .frame(width: 12, height: 12)
//            
//            Text(title)
//                .font(.system(.subheadline, design: .rounded))
//                .foregroundColor(.secondary)
//            
//            Spacer()
//            
//            Text(value)
//                .font(.system(size: 24, weight: .bold, design: .rounded))
//                .foregroundColor(.primary)
//        }
//    }
//}
//
//

//
//  immediateMemoryChart.swift
//  recap_charts
//
//  Created by admin70 on 13/11/24.
//

import SwiftUI
import Charts

struct ImmediateReportDetailViewController: View {
    @State private var immediateMemoryData: [ImmediateMemoryData] = []
    @State private var selectedDate: Date? = nil
    private let verifiedUserDocID: String
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
    }

    var body: some View {
        ZStack {
            
            Color(AppColors.cardBackgroundColor)
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Constants.paddingKeys.DefaultPaddingTop) {
                    // Data summary card
                    summaryCard
                    
                    // Date selector and chart
                    if !immediateMemoryData.isEmpty {
                        dateSelector
                        memoryChartCard
                    } else {
                        emptyStateView
                    }
                    
                    // Information section
                    informationCard
                }
                .padding(.horizontal, Constants.paddingKeys.DefaultPaddingLeft)
                .padding(.vertical, Constants.paddingKeys.DefaultPaddingTop)
            }
        }
        .navigationTitle("Immediate Memory")
        .onAppear {
            loadMemoryData()
        }
    }
    
    // MARK: - Components
    
    var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Overall Performance")
                        .font(Font(Constants.FontandColors.titleFont))
                        .foregroundColor(Color(AppColors.primaryTextColor))
                    
                    Text(calculateOverallScore())
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(AppColors.iconColor))
                }
                
                Spacer()
                
                Image(systemName: "brain.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color(AppColors.iconColor))
                                        .frame(width: 60, height: 60)
                                        .background(
                                            Circle()
                                                .fill(Color(AppColors.primaryButtonColor).opacity(0.8))
                                        )
            }
            
            if !immediateMemoryData.isEmpty {
                Text("Based on \(getTotalAnswers()) questions over \(immediateMemoryData.count) sessions")
                    .font(Font(Constants.FontandColors.descriptionFont))
                    .foregroundColor(Color(AppColors.iconColor))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.CardSize.DefaultCardCornerRadius)
                .fill(Color(AppColors.cardBackgroundColor))
                .shadow(
                    color: Color(AppColors.primaryTextColor).opacity(CGFloat(Constants.FontandColors.defaultshadowOpacity)),
                    radius: Constants.FontandColors.defaultshadowRadius,
                    x: Constants.FontandColors.defaultshadowOffset.width,
                    y: Constants.FontandColors.defaultshadowOffset.height
                )
        )
    }
    
    var dateSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(immediateMemoryData) { data in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedDate = data.date
                        }
                    }) {
                        Text(data.date.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.system(.subheadline, design: .rounded))
                            .padding(.horizontal, Constants.paddingKeys.DefaultPaddingLeft)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isDateSelected(data.date) ?
                                          Color(AppColors.primaryButtonColor) :
                                          Color(AppColors.secondaryButtonColor))
                            )
                            .foregroundColor(isDateSelected(data.date) ?
                                            Color(AppColors.primaryButtonTextColor) :
                                            Color(AppColors.primaryTextColor))
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // Helper function to check if a date is selected
    private func isDateSelected(_ date: Date) -> Bool {
        if let selectedDate = selectedDate {
            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
        }
        return false
    }
    
    var memoryChartCard: some View {
        let displayData = selectedDate == nil ?
            immediateMemoryData :
            immediateMemoryData.filter { $0.date == selectedDate }
        
        return VStack(alignment: .leading, spacing: 16) {
            if !displayData.isEmpty {
                ForEach(displayData) { data in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(data.date.formatted(.dateTime.weekday(.wide).day().month().year()))
                            .font(Font(Constants.FontandColors.titleFont))
                            .foregroundColor(Color(AppColors.primaryTextColor))
                        
                        HStack(alignment: .center) {
                            // Modern donut chart
                            ModernDonutChartView(
                                correctAnswers: data.correctAnswers,
                                incorrectAnswers: data.incorrectAnswers
                            )
                            .frame(
                                width: Constants.CardSize.DefaultCardWidth,
                                height: Constants.CardSize.DefaultCardHeight
                            )
                            
                            VStack(alignment: .leading, spacing: 16) {
                                StatItemView(
                                    title: "Correct",
                                    value: "\(data.correctAnswers)",
                                    color: Color(AppColors.successColor)
                                )
                                
                                StatItemView(
                                    title: "Incorrect",
                                    value: "\(data.incorrectAnswers)",
                                    color: Color(AppColors.errorColor)
                                )
                                
                                if data.correctAnswers + data.incorrectAnswers > 0 {
                                    StatItemView(
                                        title: "Accuracy",
                                        value: "\(Int(Double(data.correctAnswers) / Double(data.correctAnswers + data.incorrectAnswers) * 100))%",
                                        color: Color(AppColors.iconColor)
                                    )
                                }
                            }
                            .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: Constants.CardSize.DefaultCardCornerRadius)
                            .fill(Color(AppColors.cardBackgroundColor))
                            .shadow(
                                color: Color(AppColors.primaryTextColor).opacity(CGFloat(Constants.FontandColors.defaultshadowOpacity)),
                                radius: Constants.FontandColors.defaultshadowRadius,
                                x: Constants.FontandColors.defaultshadowOffset.width,
                                y: Constants.FontandColors.defaultshadowOffset.height
                            )
                    )
                }
            }
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 56))
                .foregroundColor(Color(AppColors.secondaryTextColor).opacity(0.6))
                .padding(.bottom, 8)
            
            Text("No Memory Data Available")
                .font(Font(Constants.FontandColors.titleFont))
                .foregroundColor(Color(AppColors.primaryTextColor))
            
            Text("Complete memory exercises to see your results here")
                .font(Font(Constants.FontandColors.descriptionFont))
                .foregroundColor(Color(AppColors.secondaryTextColor))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: Constants.CardSize.DefaultCardCornerRadius)
                .fill(Color(AppColors.cardBackgroundColor))
                .shadow(
                    color: Color(AppColors.primaryTextColor).opacity(CGFloat(Constants.FontandColors.defaultshadowOpacity)),
                    radius: Constants.FontandColors.defaultshadowRadius,
                    x: Constants.FontandColors.defaultshadowOffset.width,
                    y: Constants.FontandColors.defaultshadowOffset.height
                )
        )
    }
    
    var informationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About Immediate Memory")
                .font(Font(Constants.FontandColors.titleFont))
                .foregroundColor(Color(AppColors.primaryTextColor))
            
            VStack(alignment: .leading, spacing: 12) {
                insightRow(
                    icon: "timer",
                    title: "Rapid Recall",
                    description: "Your ability to remember information learned minutes ago"
                )
                
                Divider()
                
                insightRow(
                    icon: "brain.head.profile",
                    title: "Working Memory",
                    description: "Essential for problem-solving and everyday tasks"
                )
                
                Divider()
                
                insightRow(
                    icon: "arrow.up.forward",
                    title: "Improvement Tips",
                    description: "Practice attention to detail and focus during learning"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Constants.CardSize.DefaultCardCornerRadius)
                    .fill(Color(AppColors.cardBackgroundColor))
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.CardSize.DefaultCardCornerRadius)
                .fill(Color(AppColors.cardBackgroundColor))
                .shadow(
                    color: Color(AppColors.primaryTextColor).opacity(CGFloat(Constants.FontandColors.defaultshadowOpacity)),
                    radius: Constants.FontandColors.defaultshadowRadius,
                    x: Constants.FontandColors.defaultshadowOffset.width,
                    y: Constants.FontandColors.defaultshadowOffset.height
                )
        )
    }
    
    func insightRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(AppColors.iconColor))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font(Constants.FontandColors.subtitleFont))
                    .foregroundColor(Color(AppColors.primaryTextColor))
                
                Text(description)
                    .font(Font(Constants.FontandColors.descriptionFont))
                    .foregroundColor(Color(AppColors.secondaryTextColor))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadMemoryData() {
        fetchImmediateMemoryData(for: verifiedUserDocID) { data in
            DispatchQueue.main.async {
                self.immediateMemoryData = data.sorted(by: { $0.date > $1.date })
                
                // Set default selected date to today if available, otherwise most recent
                let today = Date()
                let todayData = data.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
                
                if let todayData = todayData {
                    self.selectedDate = todayData.date
                } else if !data.isEmpty {
                    self.selectedDate = data.first?.date
                }
            }
        }
    }
    
    private func calculateOverallScore() -> String {
        let totalCorrect = immediateMemoryData.reduce(0) { $0 + $1.correctAnswers }
        let totalQuestions = immediateMemoryData.reduce(0) { $0 + $1.correctAnswers + $1.incorrectAnswers }
        
        guard totalQuestions > 0 else { return "N/A" }
        
        let percentage = Double(totalCorrect) / Double(totalQuestions) * 100
        return "\(Int(percentage))%"
    }
    
    private func getTotalAnswers() -> Int {
        immediateMemoryData.reduce(0) { $0 + $1.correctAnswers + $1.incorrectAnswers }
    }
    
    private func scoreColor() -> Color {
        let score = calculateOverallScore()
        guard score != "N/A" else { return Color(AppColors.secondaryTextColor) }
        
        let percentage = Int(score.dropLast()) ?? 0
        
        switch percentage {
        case 0..<60: return Color(AppColors.errorColor)
        case 60..<75: return Color(.systemOrange) // No equivalent in AppColors, using systemOrange
        case 75..<90: return Color(AppColors.iconColor)
        default: return Color(AppColors.successColor)
        }
    }
}

// MARK: - Supporting Views

struct ModernDonutChartView: View {
    let correctAnswers: Int
    let incorrectAnswers: Int
    
    @State private var animationProgress: Double = 0
    
    var totalAnswers: Int {
        correctAnswers + incorrectAnswers
    }
    
    var correctRatio: Double {
        totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) : 0
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color(AppColors.secondaryTextColor).opacity(0.2), lineWidth: 12)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: correctRatio * animationProgress)
                .stroke(
                    Color(AppColors.successColor),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1), value: animationProgress)
            
            // Inner circle with percentage
            VStack(spacing: 0) {
                Text("\(Int(correctRatio * 100 * animationProgress))%")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(AppColors.primaryTextColor))
                    .animation(.easeOut(duration: 1), value: animationProgress)
                
                Text("Correct")
                    .font(Font(Constants.FontandColors.descriptionFont))
                    .foregroundColor(Color(AppColors.secondaryTextColor))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            }
        }
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(title)
                .font(Font(Constants.FontandColors.descriptionFont))
                .foregroundColor(Color(AppColors.secondaryTextColor))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(AppColors.primaryTextColor))
        }
    }
}

// Note: DonutChartView is not updated as it appears unused in the main view
// If needed, it can be updated similarly to use AppColors and Constants
