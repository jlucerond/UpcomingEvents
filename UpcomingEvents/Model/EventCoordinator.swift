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

         (Side note, i did think of this, and then after getting everything mostly working, I saw that you guys very purposefully tried to sneak in this scenario on the last day. Well done.)

         This made me think that it would be better to pack things into days first and then apply the algorithm above (especially with the hint in the pdf that there's no events that start and end on different days.
         */

        var eventsByDay = putIntoDays(events: events)
        sortEventsWithinEachDay(eventsByDay: &eventsByDay)
        var calendar = checkForConflictsAndReturnViewModel(eventsByDay: eventsByDay)
        sortDays(schedule: &calendar)
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
            guard !allEventsThatDay.isEmpty else { continue } // sanity check that shouldn't ever happen
            var day = Day()
            let conflicts = getConflicts(events: allEventsThatDay)
            for (index, event) in allEventsThatDay.enumerated() {
                let eventViewModel = EventViewModel(event: event, hasConflict: conflicts[index])
                day.append(eventViewModel)
            }
            calendar.append(day)
        }
        return calendar
    }

    func getConflicts(events: [Event]) -> [Bool] {
        var conflicts = [Bool]()

        for (index, event) in events.enumerated() {
            if index == 0 {
                // first event
                if events.count == 1 {
                    // only event that day, no conflict
                    conflicts.append(false)
                } else {
                    // otherwise compare first and second events
                    let nextEvent = events[1]
                    conflicts.append(doesOverlap(earlierEvent: event, laterEvent: nextEvent))
                }
            } else if index == events.count - 1 {
                // last event, check the previous event(s)
                let previousIndex = index - 1
                let previousEvent = events[previousIndex]
                let doesOverlapWithPreviousEvent = doesOverlap(earlierEvent: previousEvent, laterEvent: event)
                let watchOutForEarlierEvents = conflicts.last == true

                if watchOutForEarlierEvents && !doesOverlapWithPreviousEvent {
                    // at this point, we might have a day-long event that affected the next ten events. consecutive conflicts tells me to look back at each of those previous events and see if its end time goes past our current items start time
                    var consecutiveConflicts = 0
                    var conflictsCopy = conflicts
                    while conflictsCopy.popLast() == true {
                        consecutiveConflicts += 1
                    }
                    let startIndexToCheck = index - consecutiveConflicts
                    let eventsToCheck = Array(events[startIndexToCheck..<previousIndex])
                    conflicts.append(doesOverlap(event: event, earlierEvents: eventsToCheck))
                } else {
                    // The last event was not conflicted, so just check the next event
                    conflicts.append(doesOverlapWithPreviousEvent)
                }
            } else {
                // in between events
                let watchOutForEarlierEvents = conflicts.last == true
                let previousIndex = index - 1
                let previousEvent = events[previousIndex]
                let nextEvent = events[index+1]
                let hasNearbyOverlap = doesOverlap(earlierEvent: previousEvent, laterEvent: event) || doesOverlap(earlierEvent: event, laterEvent: nextEvent)
                if watchOutForEarlierEvents && !hasNearbyOverlap {
                    // at this point, we might have a day-long event that affected the next ten events. consecutive conflicts tells me to look back at each of those previous events and see if its end time goes past our current items start time
                    var consecutiveConflicts = 0
                    var conflictsCopy = conflicts
                    while conflictsCopy.popLast() == true {
                        consecutiveConflicts += 1
                    }
                    let startIndexToCheck = index - consecutiveConflicts
                    let eventsToCheck = Array(events[startIndexToCheck..<previousIndex])
                    conflicts.append(doesOverlap(event: event, earlierEvents: eventsToCheck))
                } else {
                    conflicts.append(hasNearbyOverlap)
                }
            }
        }

        assert(conflicts.count == events.count, "Made a mistake here.")
        return conflicts
    }

    func doesOverlap(event: Event, earlierEvents: [Event]) -> Bool {
        for eventToCheck in earlierEvents {
            if doesOverlap(earlierEvent: eventToCheck, laterEvent: event) {
                return true
            }
        }
        return false
    }

    func doesOverlap(earlierEvent: Event, laterEvent: Event) -> Bool {
        guard let earlierEnd = earlierEvent.endDate, let nextStart = laterEvent.startDate else {
            assertionFailure("Again, something must have gone wrong. I probably should have made those dates non-optional")
            return false
        }

        return earlierEnd > nextStart
    }

    func sortDays(schedule: inout Schedule) {
        schedule.sort { (day1, day2) -> Bool in
            // I do the sanity check above, so I'm not as worried about empty arrays here, but I could do a better job here
            guard let eventFromDay1 = day1.first, let eventFromDay2 = day2.first else { return false }
            return eventFromDay1 < eventFromDay2
        }
    }
}
