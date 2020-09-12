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
    
    func updateWith(event: String) {
        // TODO: - convert event to an EventViewModel for this
        textLabel?.text = event
    }
}
