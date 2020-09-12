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
    private static let warning = "exclamationmark.triangle.fill"
    @IBOutlet private weak var conflictedEventImageView: UIImageView!
    @IBOutlet private weak var eventTitleLabel: UILabel!
    @IBOutlet private weak var eventTimeLabel: UILabel!

    func updateWith(event: String) {
        // TODO: - convert event to an EventViewModel for this
        conflictedEventImageView.image = UIImage(systemName: EventTableViewCell.warning)
        eventTitleLabel.text = event
    }
}
