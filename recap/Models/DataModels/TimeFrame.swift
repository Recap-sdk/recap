//
//  TimeFrame.swift
//  recap
//
//  Created by user@47 on 08/02/25.
//


import FirebaseFirestore

// MARK: - Time Frame Struct
struct TimeFrame: Codable {
    var from: Timestamp
    var to: Timestamp

    init(from timeStringFrom: String, to timeStringTo: String) {
        let fixedDate = "2000-01-01 " // Fixed reference date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")

        let fromDate = dateFormatter.date(from: fixedDate + timeStringFrom) ?? Date()
        let toDate = dateFormatter.date(from: fixedDate + timeStringTo) ?? Date()

        self.from = Timestamp(date: fromDate)
        self.to = Timestamp(date: toDate)
    }

    // Convert Timestamp back to "HH:mm" string
    func getTimeString(from timestamp: Timestamp) -> String {
        let date = timestamp.dateValue()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        return timeFormatter.string(from: date)
    }

    var fromTimeString: String { getTimeString(from: from) }
    var toTimeString: String { getTimeString(from: to) }
}
