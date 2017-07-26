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
    
    func settingsViewModelGotData() {
        tableView.reloadData()
        tableView.isUserInteractionEnabled = true
        activityView.stopAnimating()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.toggleSelectionOfItem(at: indexPath.row)
    }
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as? SettingsCell else {
            return UITableViewCell()
        }
        let item = viewModel.items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.accessoryType = item.isChecked ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}
