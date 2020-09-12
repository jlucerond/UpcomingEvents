//
//  EventError.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import Foundation

enum EventError: String, Error {
    case unableToGetEvents
    case unableToDecodeEvents

    // Not realistic, but just to show one way to use these types of errors for cleanliness elsewhere
    var userMessage: String {
        switch self {
        case .unableToGetEvents:
            return "Unable to get your events. Try again later."
        case .unableToDecodeEvents:
            return "We are currently working on updating our app. Please bear with us."
        }
    }

    var localizedDescription: String {
        "EventError: '\(self)'"
    }
}
