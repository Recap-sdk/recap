//
//  status.swift
//  Recap
//
//  Created by khushi on 30/11/24.
//


import SwiftUICore
enum MemoryStatus: String {
    case improving = "Improving"
    case processing = "Processing"
    case stable = "Stable"
    case declining = "Declining"
}
func calculateAverageStatus(correctAnswers: Int, incorrectAnswers: Int) -> (average: Double, status: MemoryStatus) {
    let totalAnswers = correctAnswers + incorrectAnswers
    guard totalAnswers > 0 else { return (0.0, .declining) }
    
    let average = (Double(correctAnswers) / Double(totalAnswers)) * 100

    let status: MemoryStatus
    switch average {
    case 80...100:
        status = .improving
    case 70..<80:
        status = .processing
    case 60..<70:
        status = .stable
    default:
        status = .declining
    }

    return (average, status)
}

