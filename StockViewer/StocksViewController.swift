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

    @IBAction func editButtonClicked(_ sender: UIBarButtonItem) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
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
            if !tableView.isEditing {
                tableView.reloadData()
            }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let items = viewModel.items else {
            return
        }
        let item = items[indexPath.row]
        performSegue(withIdentifier: "GraphSegue", sender: StockSymbol(rawValue: item.name))
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
}

extension StocksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let items = viewModel.items, let cell = tableView.dequeueReusableCell(withIdentifier: "StocksCell", for: indexPath) as? StocksCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        
        // use denormalization instead of last tick
        //let lastTick = item.ticks.sorted(byKeyPath: "date").last ?? TickEntity()
        let lastSpread = item.lastSpread //lastTick.spread
        let lastBid = item.lastBid //lastTick.bid
        let lastAsk = item.lastAsk //lastTick.ask
        
        //| EUR/USD | 1.12812 / 1.12820 | 0.8 |
        cell.symbol.text = StockSymbol(rawValue: item.name)?.description
        cell.spread.text = "\(lastSpread)"
        cell.bidask.text = "\(lastBid) / \(lastAsk)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.toggleIsActiveOfItem(at: indexPath.row)
            self.tableView.setEditing(false, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.changePositions(src:sourceIndexPath.row, dest:destinationIndexPath.row)
        self.tableView.setEditing(false, animated: true)
    }

}

