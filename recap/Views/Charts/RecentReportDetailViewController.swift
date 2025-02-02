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
                BarMark(
                    x: .value("Week", dayData.week),
                    y: .value("Correct Answers", dayData.correctAnswers)
                )
                .foregroundStyle(Color.customLightPurple)
                
                BarMark(
                    x: .value("Week", dayData.week),
                    y: .value("Incorrect Answers", dayData.incorrectAnswers)
                )
                .foregroundStyle(Color.customLightRed)
                .annotation(position: .top) {
                    Text("\(dayData.correctAnswers + dayData.incorrectAnswers)")
                        .font(.caption)
                        .foregroundColor(.primary)
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
    var data: [RecentMemoryData]
    
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
                    
                    // Bar Chart section
                    VStack(spacing: 15) {
                        BarChartView(data: data)
                            .frame(width: 300, height: 250) // Standardized dimensions
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                            .padding(.horizontal)
                    }
                    
                    // Chart Legend section
                    HStack {
                        Label("Correct", systemImage: "circle.fill")
                            .foregroundColor(.customLightPurple)
                            .font(.caption2)
                        
                        Label("Incorrect", systemImage: "circle.fill")
                            .foregroundColor(.customLightRed)
                            .font(.caption2)
                    }
                    .padding(.horizontal)
                    
                    // About Insights section
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
    }
}

struct RecentReportDetailViewController_Previews: PreviewProvider {
    static var previews: some View {
        RecentReportDetailViewController(data: recentMemoryData)
    }
}
