//
//  EventCoordinator.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import Foundation

class EventCoordinator {
    // Singleton because it's a simple app and it shows that I know how to privatize the init properly
    // Comment because singletons don't scale or work well with unit testing
    static let shared = EventCoordinator()
    private init() {}
    typealias Day = [EventViewModel]
    typealias Schedule = [Day]

    // Did a Result here with a completion handler rather than throwing errors since in the real world this would come from some network service
    func getEvents(completion: @escaping(Result<Schedule, EventError>) -> Void) {
        guard let urlForMockData = Bundle.main.url(forResource: "mock", withExtension: "json"), let data = try? Data.init(contentsOf: urlForMockData) else {
            completion(.failure(.unableToGetEvents))
            return
        }

        guard let events = try? JSONDecoder().decode([Event].self, from: data) else {
            completion(.failure(.unableToDecodeEvents))
            return
        }

        let calendar = sortAndConvertToCalendar(events: events)

        completion(.success(calendar))
    }
}

private extension EventCoordinator {
    func sortAndConvertToCalendar(events: [Event]) -> Schedule {
        /*
         Here's where you're looking for my sub-O(n^2) algorithm and I do my best to explain my thought process. Full disclosure- this is one of my weaker areas as a programmer since I don't have a CS background so I'm interested in your thoughts on this.

         My first attempt at this was to just sort the events and then check the event before and after to see if either one conflicted. The issue with this is that you could have a meeting an hour ago that went only ten minutes, but an all day event that started before the earlier meeting might still conflict. So I'd need to check if the earlier event overlaps OR whether it itself has a conflict, because then I would need to recursively go backwards to see any potential conflicts.

         This made me think that it would be better to pack things into days first and then apply the algorithm above (especially with the hint in the pdf that there's no events that start and end on different days.
         */

        var eventsByDay = putIntoDays(events: events)
        sortEventsWithinEachDay(eventsByDay: &eventsByDay)
        let calendar = checkForConflictsAndReturnViewModel(eventsByDay: eventsByDay)
        // TODO: - because we converted to a dictionary, we may have lost the order of the days here
        return calendar
    }

    typealias UniqueDateString = String
    typealias EventsByDay = [UniqueDateString: [Event]]

    // Start by putting events into a dictionary, i.e. ["Jan 1, 2021": [event3, event1, event2]]
    func putIntoDays(events: [Event]) -> EventsByDay {
        var eventsByDay = [UniqueDateString: [Event]]()
        for event in events {
            let dayString = event.dayString ?? "Unknown"
            if eventsByDay[dayString] == nil {
                eventsByDay[dayString] = [event]
            } else {
                eventsByDay[dayString]?.append(event)
            }
        }
        return eventsByDay
    }

    // Next use inout parameter to sort the events by start date (as done in Event's comparable adherence, i.e. ["Jan 1, 2021": [event1, event2, event3]]. Because we're doing this with smaller sets of data rather than one big chunk, it should also be more performant.
    func sortEventsWithinEachDay(eventsByDay: inout EventsByDay) {
        for day in eventsByDay.keys {
            eventsByDay[day]?.sort()
        }
    }

    // Finally, convert each event into an EventViewModel and check for conflicts along the way
    func checkForConflictsAndReturnViewModel(eventsByDay: EventsByDay) -> Schedule {
        var calendar = [[EventViewModel]]()
        for allEventsThatDay in eventsByDay.values {
            var day = Day()
            for (index, event) in allEventsThatDay.enumerated() {
                // TODO: - finish this, but sanity check that it still works first
                if index == 0 {
                    let event = EventViewModel(event: event, hasConflict: true)
                    day.append(event)
                } else if index == allEventsThatDay.count - 1 {
                    let event = EventViewModel(event: event, hasConflict: false)
                    day.append(event)
                } else {
                    let event = EventViewModel(event: event, hasConflict: false)
                    day.append(event)
                }
            }
            calendar.append(day)
        }
        return calendar
    }
}
