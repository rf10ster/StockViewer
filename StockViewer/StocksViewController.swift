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
        guard let graphVC = segue.destination as? GraphViewController, let symbol = sender as? StockSymbol else {
            return
        }
        graphVC.symbol = symbol
        graphVC.title = symbol.description
    }

}

extension StocksViewController: StocksViewModelDelegate {
    
    func stocksViewModelFetchingData() {
        tableView.isUserInteractionEnabled = false
        activityView.startAnimating()
    }
    
    func stocksViewModelGotData(result: ResultType) {
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

extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let items = viewModel.items else {
            return
        }
        let item = items[indexPath.row]
        performSegue(withIdentifier: "GraphSegue", sender: StockSymbol(rawValue: item.name))
    }
}

extension StocksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = viewModel.items, let cell = tableView.dequeueReusableCell(withIdentifier: "StocksCell", for: indexPath) as? StocksCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        let lastTick = item.ticks.sorted(byKeyPath: "date").last ?? TickEntity()
        //| EUR/USD | 1.12812 / 1.12820 | 0.8 |
        cell.symbol.text = StockSymbol(rawValue: item.name)?.description
        cell.spread.text = "\(lastTick.spread)"
        cell.bidask.text = "\(lastTick.bid) / \(lastTick.ask)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items?.count ?? 0
    }
}

