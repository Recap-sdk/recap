//
//  RemoteDataModel.swift
//  Recap
//
//  Created by admin70 on 29/10/24.
//



let mayWeeklyData: [RecentMemoryData] = [
    RecentMemoryData(week: "Mon", correctAnswers: 18, incorrectAnswers: 2),
    RecentMemoryData(week: "Tue", correctAnswers: 12, incorrectAnswers: 8),
    RecentMemoryData(week: "Wed", correctAnswers: 10, incorrectAnswers: 10),
    RecentMemoryData(week: "Thu", correctAnswers: 14, incorrectAnswers: 6),
    RecentMemoryData(week: "Fri", correctAnswers: 11, incorrectAnswers: 9),
    RecentMemoryData(week: "Sat", correctAnswers: 9, incorrectAnswers: 11),
    RecentMemoryData(week: "Sun", correctAnswers: 14, incorrectAnswers: 6)
]

let juneWeeklyData: [RecentMemoryData] = [
    RecentMemoryData(week: "Mon", correctAnswers: 20, incorrectAnswers: 0),
    RecentMemoryData(week: "Tue", correctAnswers: 15, incorrectAnswers: 5),
    RecentMemoryData(week: "Wed", correctAnswers: 14, incorrectAnswers: 6),
    RecentMemoryData(week: "Thu", correctAnswers: 18, incorrectAnswers: 2),
    RecentMemoryData(week: "Fri", correctAnswers: 16, incorrectAnswers: 4),
    RecentMemoryData(week: "Sat", correctAnswers: 13, incorrectAnswers: 7),
    RecentMemoryData(week: "Sun", correctAnswers: 17, incorrectAnswers: 3)
]

struct MonthlyMemoryData {
    let month: String
    let weeklyData: [RecentMemoryData]
    
    
    var monthlyAverageScore: Double {
        let totalWeeklyScores = weeklyData.reduce(0) { $0 + (Double($1.correctAnswers) / Double($1.correctAnswers + $1.incorrectAnswers)) * 100 }
        return totalWeeklyScores / Double(weeklyData.count)
    }
}

let monthlyMemoryData: [MonthlyMemoryData] = [
    MonthlyMemoryData(month: "May", weeklyData: mayWeeklyData),
    MonthlyMemoryData(month: "June", weeklyData: juneWeeklyData)
]


import Foundation

struct MonthlyReport: Identifiable {
    let id = UUID()
    let date: Date
    let correctAnswers: Int
}

let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

let startDate = formatter.date(from: "2024-11-01")!
let endDate = formatter.date(from: "2024-11-30")!

func generateFakeMonthlyData(startDate: Date, endDate: Date) -> [MonthlyReport] {
    var reports: [MonthlyReport] = []
    var currentDate = startDate
    
    while currentDate <= endDate {
        let randomCorrectAnswers = Int.random(in: 0...20)
        let report = MonthlyReport(date: currentDate, correctAnswers: randomCorrectAnswers)
        reports.append(report)
        
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
    }
    
    return reports
}

let novemberReports = generateFakeMonthlyData(startDate: startDate, endDate: endDate)
