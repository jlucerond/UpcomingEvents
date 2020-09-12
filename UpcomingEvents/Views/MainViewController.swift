//
//  MainViewController.swift
//  UpcomingEvents
//
//  Created by Joe Lucero on 9/11/20.
//  Copyright © 2020 Joe Lucero. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    private let tableTitle = "Upcoming Events"
    private var isLoadingData = false
    private var schedule = EventCoordinator.Schedule()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = tableTitle
        getEvents()
    }
}

// MARK: - TableViewDataSource Methods
extension MainViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard !isLoadingData else { return 1 }
        return schedule.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !isLoadingData else { return 1 }
        return schedule[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !isLoadingData else {
            return tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: EventTableViewCell.identifier, for: indexPath) as? EventTableViewCell else {
            assertionFailure("TableView does not have an EventTableViewCell ready to dequeue")
            return UITableViewCell()
        }

        let event = schedule[indexPath.section][indexPath.row]
        cell.updateWith(event: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !isLoadingData else { return nil }
        return schedule[section].first?.headerLabel
    }
}

// MARK: - Private Helper Methods
private extension MainViewController {
    private var errorTitle: String { "Unable to Get Upcoming Events" }

    func getEvents() {
        isLoadingData = true
        EventCoordinator.shared.getEvents { [weak self] result in
            guard let self = self else { return }
            self.isLoadingData = false
            switch result {
            case .success(let events):
                self.schedule = events
                self.tableView.reloadData()
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
