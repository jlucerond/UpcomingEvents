//
//  UITableMainViewControllerViewController.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    private let tableTitle = "Upcoming Events"
    var testStrings = ["a", "b", "c"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tableTitle
        // TODO: - make a call to the EventCoordinator to get data and update the TableView
    }
}

// MARK: - TableViewDataSource Methods
extension MainViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            assertionFailure("Not designed to have multiple sections at the moment")
            return 0
        }

        return testStrings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as? EventTableViewCell else {
            assertionFailure("TableView does not have an EventTableViewCell ready to dequeue")
            return UITableViewCell()
        }

        let event = testStrings[indexPath.row]
        cell.updateWith(event: event)
        return cell
    }
}

