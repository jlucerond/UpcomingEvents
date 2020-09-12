//
//  EventViewModel.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import Foundation

struct EventViewModel {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    private let event: Event
    let hasConflict: Bool
    var titleLabel: String { event.start + "\n" + event.end }
    var times: (start: String, end: String)? {
        guard let startDate = event.startDate, let endDate = event.endDate else { return nil }
        return (EventViewModel.timeFormatter.string(from: startDate), EventViewModel.timeFormatter.string(from: endDate))
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
