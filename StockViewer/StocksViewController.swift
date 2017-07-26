//
//  StocksViewController.swift
//  StockViewer
//
//  Created by Алексей Киселев on 26/07/2017.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import UIKit

class StocksViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    fileprivate var viewModel: StocksViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        viewModel = StocksViewModel()
        viewModel.delegate = self
        viewModel.fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let graphVC = segue.destination as? GraphViewController, let stock = sender else {
            return
        }
        graphVC.stock = "NA"
        graphVC.title = "Some stock"
    }

}

extension StocksViewController: StocksViewModelDelegate {
    
    func stocksViewModelFetchingData() {
        tableView.isUserInteractionEnabled = false
        activityView.startAnimating()
    }
    
    func stocksViewModelGotData() {
        tableView.reloadData()
        tableView.isUserInteractionEnabled = true
        activityView.stopAnimating()
    }
}

extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = viewModel.items[indexPath.row]
        performSegue(withIdentifier: "GraphSegue", sender: item)
    }
}

extension StocksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StocksCell", for: indexPath) as? StocksCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}

