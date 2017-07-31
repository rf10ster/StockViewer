//
//  SettingsViewController.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/26/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    fileprivate var viewModel: SettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        viewModel = SettingsViewModel()
        viewModel.delegate = self
        viewModel.fetchData()
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    
    func settingsViewModelFetchingData() {
        tableView.isUserInteractionEnabled = false
        activityView.startAnimating()
    }
    
    func settingsViewModelGotData(result: ResultType) {
        tableView.isUserInteractionEnabled = true
        activityView.stopAnimating()
        switch result {
        case .success:
            tableView.reloadData()
        case let .failure(error: error):
            var alerttitle: String? = nil
            var alertmessage: String? = nil
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            switch error {
            case StockViewerError.jsonError:
                alerttitle = "Error in parsing json"
            case let StockViewerError.databaseError(databaseError):
                alerttitle = "Error in database"
                alertmessage = (databaseError as NSError?)?.localizedDescription
            case let StockViewerError.connectionError(connectionError):
                alerttitle = "Error in networkservice"
                alertmessage = (connectionError as NSError?)?.localizedDescription
                let defaultAction = UIAlertAction(title: "Reconnect", style: .default) { _ in
                    self.viewModel.reconnect()
                }
                alert.addAction(defaultAction)
            default:
                alerttitle = "General error"
            }
            alert.title = alerttitle
            alert.message = alertmessage
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.toggleSelectionOfItem(at: indexPath.row)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = viewModel.items, let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.titleLabel.text = StockSymbol(rawValue: item.name)?.description
        cell.accessoryType = item.isActive ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items?.count ?? 0
    }
}
