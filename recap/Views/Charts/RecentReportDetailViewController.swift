//
//  RecentMemoryChart.swift
//  recap_charts
//
//  Created by admin70 on 13/11/24.
//

import SwiftUI
import Charts

struct BarChartView: View {
    var data: [RecentMemoryData]
    
    var body: some View {
        Chart {
            ForEach(data) { dayData in
                let shortDay = String(dayData.day.prefix(3)) // Use only first 3 letters
                let total = dayData.correctAnswers + dayData.incorrectAnswers
                let maxValue = max(dayData.correctAnswers, dayData.incorrectAnswers) // Highest bar value

                BarMark(
                    x: .value("Day", shortDay),
                    y: .value("Correct", dayData.correctAnswers)
                )
                .foregroundStyle(Color.customLightPurple)
                .annotation(position: .top, alignment: .center) {
                    if dayData.correctAnswers >= dayData.incorrectAnswers {
                        Text("\(total)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }

                BarMark(
                    x: .value("Day", shortDay),
                    y: .value("Incorrect", dayData.incorrectAnswers)
                )
                .foregroundStyle(Color.customLightRed)
                .annotation(position: .top, alignment: .center) {
                    if dayData.incorrectAnswers > dayData.correctAnswers {
                        Text("\(total)")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .stride(by: 5))
        }
        .frame(width: 250, height: 250)
        .padding()
        .padding(.horizontal)
    }
}




struct RecentReportDetailViewController: View {
    let verifiedUserDocID: String
    @StateObject private var recentMemoryDataModel = RecentMemoryDataModel()

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.8, green: 0.93, blue: 0.95), Color(red: 1.0, green: 0.88, blue: 0.88)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Title section
                    HStack {
                        Spacer()
                        Text("Recent Memory")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Week Navigation Buttons
                    HStack {
                        Button(action: {
                            recentMemoryDataModel.goToPreviousWeek(for: verifiedUserDocID, selectedMonth: getCurrentMonth())
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(recentMemoryDataModel.selectedWeekIndex > 0 ? .black : .gray)
                        }
                        .disabled(recentMemoryDataModel.selectedWeekIndex == 0)

                        Text("Week \(recentMemoryDataModel.selectedWeekIndex + 1)")
                            .font(.headline)
                            .padding(.horizontal)

                        Button(action: {
                            recentMemoryDataModel.goToNextWeek(for: verifiedUserDocID, selectedMonth: getCurrentMonth())
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundColor(recentMemoryDataModel.selectedWeekIndex < recentMemoryDataModel.availableWeeks.count - 1 ? .black : .gray)
                        }
                        .disabled(recentMemoryDataModel.selectedWeekIndex == recentMemoryDataModel.availableWeeks.count - 1)
                    }
                    .padding(.horizontal)

                    // Bar Chart Section
                    VStack(spacing: 15) {
                        BarChartView(data: recentMemoryDataModel.recentMemoryData)
                            .frame(width: 300, height: 250)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                            .padding(.horizontal)
                    }

                    // Chart Legend Section
                    HStack {
                        Label {
                            Text("Correct")
                                .font(.caption2)
                        } icon: {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.customLightPurple)
                        }
                        
                        Spacer()
                        
                        Label {
                            Text("Incorrect")
                                .font(.caption2)
                        } icon: {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.customLightRed)
                        }
                    }
                    .padding(.horizontal)

                    // About Insights Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Recent Insights")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("""
                        Your recent memory insights analyze your ability to recall information from the last week. This section evaluates how well you retain details from recent interactions, helping to monitor your short-term memory.

                        A strong performance in this area indicates healthy short-term recall. Identifying trends can provide insights into cognitive health over time.
                        """)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .onAppear {
            let currentMonth = getCurrentMonth()
            recentMemoryDataModel.fetchWeeks(for: verifiedUserDocID, selectedMonth: currentMonth)
        }
    }

    private func getCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}
