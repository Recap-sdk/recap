//
//  Untitled.swift
//  recap_charts
//
//  Created by admin70 on 13/11/24.
//

import SwiftUI
import Charts

struct LineChartView: View {
    let data: [MonthlyReport]
    let threshold: Int
    
    var body: some View {
        Chart {
            ForEach(data) { report in
                // Line for correct answers
                LineMark(
                    x: .value("Date", report.date, unit: .day),
                    y: .value("Correct Answers", report.correctAnswers)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            
            // Threshold line
            RuleMark(
                y: .value("Threshold", threshold)
            )
            .foregroundStyle(.red)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(width: 250, height: 250) // Standardized dimensions
        .padding()
        .padding(.horizontal)
    }
}

struct RemoteReportDetailViewController: View {
    let monthlyData: [MonthlyReport]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.93, blue: 0.95),
                    Color(red: 1.0, green: 0.88, blue: 0.88)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Title section
                    HStack {
                        Spacer()
                        Text("Remote Memory")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Line Chart section
                    VStack(spacing: 15) {
                        LineChartView(data: monthlyData, threshold: 15)
                            .frame(width: 300, height: 250) // Matches the chart dimensions from code 1
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                            .padding(.horizontal)
                    }

                    // About Insights section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Remote Insights")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("""
                        Remote memory refers to your ability to recall events or information from the distant past, typically over a week or more. By tracking your performance over time, we can observe trends that help you and your caregivers understand how well your long-term memory is functioning.
                        """)
                            .font(.body)
                            .foregroundColor(.black)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        RemoteReportDetailViewController(monthlyData: novemberReports)
    }
}

struct RemoteReportDetailViewController_Previews: PreviewProvider {
    static var previews: some View {
        RemoteReportDetailViewController(monthlyData: novemberReports)
            .previewLayout(.device)
    }
}
