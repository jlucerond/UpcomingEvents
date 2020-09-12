//
//  EventViewModel.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import Foundation

struct EventViewModel {
    private let event: Event
    let hasConflict: Bool
    var titleLabel: String { event.title }
    var times: (start: String, end: String)? {
        guard let startDate = event.startDate, let endDate = event.endDate else { return nil }
        return (EventViewModel.timeFormatter.string(from: startDate), EventViewModel.timeFormatter.string(from: endDate))
    }
    var headerLabel: String? {
        guard let startDate = event.startDate else { return nil }
        return EventViewModel.dayFormatter.string(from: startDate)
    }
    var accessibilityLabel: String {
        var string = ""
        if hasConflict {
            string += "Conflicted event: "
        }
        string += event.title

        if let times = times {
            string += ". From \(times.start) to \(times.end)."
        }
        return string
    }
    
    init(event: Event, hasConflict: Bool) {
        self.event = event
        self.hasConflict = hasConflict
    }
}

// MARK: - Comparable
extension EventViewModel: Comparable {
    static func < (lhs: EventViewModel, rhs: EventViewModel) -> Bool {
        lhs.event < rhs.event
    }
}

// MARK: - Formatters
private extension EventViewModel {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
}
