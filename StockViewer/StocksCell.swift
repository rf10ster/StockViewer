//
//  StocksCell.swift
//  StockViewer
//
//  Created by Aleksey Kiselev on 7/27/17.
//  Copyright © 2017 Алексей Киселев. All rights reserved.
//

import UIKit

class StocksCell: UITableViewCell {

    @IBOutlet weak var spread: UILabel!
    @IBOutlet weak var bidask: UILabel!
    @IBOutlet weak var symbol: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
