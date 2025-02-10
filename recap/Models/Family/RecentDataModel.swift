//
//  RecentDataModel.swift
//  Recap
//
//  Created by admin70 on 29/10/24.
//

import Foundation
import SwiftUI

struct RecentMemoryData: Identifiable {
    let id = UUID()
    let week: String
    let correctAnswers: Int
    let incorrectAnswers: Int
    var status: MemoryStatus {
        return calculateAverageStatus(correctAnswers: correctAnswers, incorrectAnswers: incorrectAnswers).status
        }
}

// Sample data
let recentMemoryData = [
    RecentMemoryData(week: "Mon", correctAnswers: 18, incorrectAnswers: 2),
    RecentMemoryData(week: "Tue", correctAnswers: 12, incorrectAnswers: 8),
    RecentMemoryData(week: "Wed", correctAnswers: 10, incorrectAnswers: 10),
    RecentMemoryData(week: "Thu", correctAnswers: 14, incorrectAnswers: 6),
    RecentMemoryData(week: "Fri", correctAnswers: 11, incorrectAnswers: 9),
    RecentMemoryData(week: "Sat", correctAnswers: 9, incorrectAnswers: 11),
    RecentMemoryData(week: "Sun", correctAnswers: 14, incorrectAnswers: 6)
]

