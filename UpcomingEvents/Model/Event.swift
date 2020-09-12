//
//  Event.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import Foundation

struct Event: Codable {
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter
    }()

    let title: String
    let start: String
    let end: String

    var startDate: Date? {
        Event.dateFormatter.date(from: start)
    }

    var endDate: Date? {
        Event.dateFormatter.date(from: end)
    }
}

// MARK: - Comparable & Equatable
extension Event: Comparable {
    static func < (lhs: Event, rhs: Event) -> Bool {
        // First make sure that we can convert start times to dates
        switch getEarlierDate(lhs: lhs.startDate, rhs: rhs.startDate) {
        case .left:
            return true
        case .right:
            return false
        case .unknown:
            // I considered putting shorter or longer events first, but I decided to go with putting 'tied' events alphabetically by title
            return lhs.title < rhs.title
        }
    }

    private static func getEarlierDate(lhs: Date?, rhs: Date?) -> Earlier {
        switch (lhs == nil, rhs == nil) {
        case (true, true):
            assertChangeInDateStyle()
            return .unknown
        case (true, false):
            // Let's put things without start dates at the end of the list
            assertChangeInDateStyle()
            return .left
        case (false, true):
            // Let's put things without start dates at the end of the list
            assertChangeInDateStyle()
            return .right
        case (false, false):
            guard let leftDate = lhs, let rightDate = rhs else {
                return .unknown
            }
            // This is the happy path and where everything should go. I know it's a bit more work and adds some extra calls to the stack trace, but just trying to show all of the wonderful ways that things could go wrong.
            if leftDate == rightDate {
                return .unknown
            } else {
                return leftDate < rightDate ? .left : .right
            }
        }
    }

    private static func assertChangeInDateStyle() {
        assertionFailure("Changes in date styling may cause the app to not show date information as intended")
    }

    enum Earlier {
        case left, right, unknown
    }
}

// MARK: - Custom Debug String Convertible
extension Event: CustomDebugStringConvertible {
    var debugDescription: String {
        "'\(title)':\n\(start) - \(end)"
    }
}
