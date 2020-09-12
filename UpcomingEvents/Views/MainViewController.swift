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
    private var events = [EventViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tableTitle
        getEvents()
    }
}

// MARK: - TableViewDataSource Methods
extension MainViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else {
            assertionFailure("Not designed to have multiple sections at the moment")
            return 0
        }

        return events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as? EventTableViewCell else {
            assertionFailure("TableView does not have an EventTableViewCell ready to dequeue")
            return UITableViewCell()
        }

        let event = events[indexPath.row]
        cell.updateWith(event: event)
        return cell
    }
}

// MARK: - Private Helper Methods
private extension MainViewController {
    private var errorTitle: String { "Unable to Get Upcoming Events" }

    func getEvents() {
        EventCoordinator.shared.getEvents { result in
            switch result {
            case .success(let events):
                self.events = events
            case .failure(let error):
                self.handleErrorRetrieveingEvents(error: error)
            }
        }
    }

    func handleErrorRetrieveingEvents(error: EventError) {
        let alert = UIAlertController(title: errorTitle, message: error.userMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
