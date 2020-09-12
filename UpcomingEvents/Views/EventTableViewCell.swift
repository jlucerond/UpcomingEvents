//
//  EventTableViewCell.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    static let identifier = "EventTableViewCell"
    private static let warningIdentifier = "exclamationmark.triangle.fill"
    @IBOutlet private weak var conflictedEventImageView: UIImageView!
    @IBOutlet private weak var eventTitleLabel: UILabel!
    @IBOutlet private weak var startTimeLabel: UILabel!
    @IBOutlet private weak var endTimeLabel: UILabel!

    func updateWith(event: EventViewModel) {
        conflictedEventImageView.image = event.hasConflict ? UIImage(systemName: EventTableViewCell.warningIdentifier) : nil
        updateLabels(using: event)
        updateAccessibility(using: event)
    }
}

private extension EventTableViewCell {
    func updateLabels(using event: EventViewModel) {
        eventTitleLabel.text = event.titleLabel
        let times = event.times
        startTimeLabel.text = times?.start
        endTimeLabel.text = times?.end
    }

    func updateAccessibility(using event: EventViewModel) {
        accessibilityLabel = event.accessibilityLabel
    }
}
