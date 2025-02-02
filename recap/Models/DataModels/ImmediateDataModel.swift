//

import Foundation
import SwiftUI

struct ImmediateMemoryData: Identifiable {
    let id = UUID()
    let date: Date
    let correctAnswers: Int
    let incorrectAnswers: Int
    var status: MemoryStatus
}

let immediateMemoryData = [
    ImmediateMemoryData(date: Date(), correctAnswers: 8, incorrectAnswers: 2, status: .improving),
]
