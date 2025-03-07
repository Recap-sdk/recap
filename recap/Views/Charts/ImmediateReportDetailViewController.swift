//
//  immediateMemoryChart.swift
//  recap_charts
//
//  Created by admin70 on 13/11/24.
//

import SwiftUI

struct ImmediateReportDetailViewController: View {
    @State private var immediateMemoryData: [ImmediateMemoryData] = []
    private let verifiedUserDocID: String
    
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        print("✅ ImmediateReport initialized with User Doc ID: \(verifiedUserDocID)")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.8, green: 0.93, blue: 0.95), Color(red: 1.0, green: 0.88, blue: 0.88)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Text("Immediate Memory")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)

                    VStack(spacing: 15) {
                        if immediateMemoryData.isEmpty {
                            Text("No memory data available")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(immediateMemoryData) { data in
                                VStack(spacing: 10) {
                                    Text("Date: \(data.date, formatter: DateFormatter.shortDate)")
                                        .font(.subheadline)
                                        .padding(.top)

                                    if data.correctAnswers + data.incorrectAnswers > 0 {
                                        DonutChartView(correctAnswers: data.correctAnswers, incorrectAnswers: data.incorrectAnswers)
                                            .frame(width: 300, height: 200)
                                            .padding()
                                    } else {
                                        Text("No data available for this date")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .padding()
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                                .shadow(radius: 5)
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("About Immediate Insights")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("""
                        Your immediate memory helps you retain information learned just a few minutes ago. This section tracks how well you remember recent activities and conversations.

                        Short-term memory is essential for processing recent information. Consistently performing well here indicates strong immediate recall abilities.
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
        .onAppear {
            print("Fetching data...")
            loadMemoryData()
        }
    }
    
    /// Fetches immediate memory data from Firestore
    private func loadMemoryData() {
        fetchImmediateMemoryData(for: verifiedUserDocID) { data in
            DispatchQueue.main.async {
                self.immediateMemoryData = data
                print("Fetched Data:", data)
            }
        }
    }
}

struct DonutChartView: View {
    let correctAnswers: Int
    let incorrectAnswers: Int

    var body: some View {
        let totalAnswers = correctAnswers + incorrectAnswers
        let correctFraction = totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) : 0
        let incorrectFraction = totalAnswers > 0 ? Double(incorrectAnswers) / Double(totalAnswers) : 0

        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)

            if totalAnswers > 0 {
                Circle()
                    .trim(from: 0, to: correctFraction)
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.customLightPurple]), center: .center), lineWidth: 40)
                    .rotationEffect(.degrees(-90))

                Circle()
                    .trim(from: correctFraction, to: correctFraction + incorrectFraction)
                    .stroke(AngularGradient(gradient: Gradient(colors: [Color.customLightRed]), center: .center), lineWidth: 40)
                    .rotationEffect(.degrees(-90))
            } else {
                Text("No memory data")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Circle()
                .fill(Color.white)
                .frame(width: 180, height: 180)

            VStack {
                Text(totalAnswers > 0 ? "\(correctAnswers) / \(totalAnswers)" : "No Data")
                    .font(.headline)
                if totalAnswers > 0 {
                    Text("Correct")
                        .font(.subheadline)
                }
            }
        }
        .frame(width: 190, height: 190)
    }
}

// Date Formatter Extension
extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

//struct ImmediateReportDetailViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        ImmediateReportDetailViewController()
//    }
//}
