//
//  GraphViewController.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import UIKit
import Charts

class GraphViewController: UIViewController {
    
    var symbol: StockSymbol!
    
    @IBOutlet weak var chartView: CandleStickChartView!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    fileprivate var viewModel: GraphViewModel!
    
    fileprivate weak var axisFormatDelegate: IAxisValueFormatter?
    
    fileprivate var previousDataCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = GraphViewModel(symbol: symbol)
        viewModel.delegate = self
        viewModel.fetchData()
        chartView.noDataText = "You need to provide data for the chart."
        axisFormatDelegate = self
        chartView.scaleYEnabled = false
        // for showing time instead of index
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = axisFormatDelegate
        xAxis.labelPosition = .bottom
        chartView.chartDescription?.text = "Double tap for zooming"
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 0.0)
        
        
        /*
         let yAxis = chartView.leftAxis
         /// Extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
         open var spaceMin: Double
         
         /// Extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
         open var spaceMax: Double
         
         /// the total range of values this axis covers
         open var axisRange: Double
         
         chartView.zoomIn
         chartView.resetZoom
         chartView.fitscreen
         */

    }
    
    fileprivate func updateChart() {
        guard let items = viewModel.items else {
            return
        }

        
        var dataEntries: [CandleChartDataEntry] = []
        // TODO: add only new values based on previousDataCount
        // ChartBaseDataSet.addEntry
        for item in items {
            // if there will be big gaps in graphic just use *index*
            let xAxisValue = item.date.timeIntervalSince1970
            
            let dataEntry = CandleChartDataEntry(x: Double(xAxisValue), shadowH: max(item.ask, item.bid), shadowL: min(item.ask, item.bid), open: item.ask, close: item.bid)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = CandleChartDataSet(values: dataEntries, label: nil)
        chartDataSet.colors = ChartColorTemplates.liberty() //[UIColor.red]
        let chartData = CandleChartData(dataSet: chartDataSet)
        chartView.data = chartData
        
        previousDataCount = items.count
    }

}

extension GraphViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm.ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}

extension GraphViewController: GraphViewModelDelegate {
    
    func graphViewModelFetchingData() {
        activityView.startAnimating()
    }
    
    func graphViewModelGotData(result: ResultType) {
        activityView.stopAnimating()
        switch result {
        case .success:
            updateChart()
            break
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
