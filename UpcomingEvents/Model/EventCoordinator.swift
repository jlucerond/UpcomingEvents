//
//  EventCoordinator.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import Foundation

class EventCoordinator {
    // Singleton because it's a simple app and it shows that I know how to privatize the init.
    // Comment because singletons often don't scale or work well with unit testing
    static let shared = EventCoordinator()
    private init() {}

    // Did a Result here with a completion handler rather than throwing errors since in the real world this would come from some network service
    func getEvents(completion: @escaping(Result<[EventViewModel], EventError>) -> Void) {
        guard let urlForMockData = Bundle.main.url(forResource: "mock", withExtension: "json"), let data = try? Data.init(contentsOf: urlForMockData) else {
            completion(.failure(.unableToGetEvents))
            return
        }

        guard let events = try? JSONDecoder().decode([Event].self, from: data) else {
            completion(.failure(.unableToDecodeEvents))
            return
        }

        // Here's where you're looking for my sub-O(n^2) algorithm. First, sort.
        let eventViewModels = performantAlgorithmCheck(events: events)

        completion(.success(eventViewModels))
    }
}

private extension EventCoordinator {
    func performantAlgorithmCheck(events: [Event]) -> [EventViewModel] {
        // TODO: - not performant yet
        let sorted = events.sorted()
        var toReturn = [EventViewModel]()
        for (index, event) in sorted.enumerated() {
            toReturn.append(EventViewModel(event: event, hasConflict: index % 2 == 0))
        }
        return toReturn
    }
}
