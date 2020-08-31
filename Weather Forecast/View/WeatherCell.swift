//
//  WeatherCell.swift
//  Weather Forecast
//
//  Created by Bindu Maharudrappa on 30.08.20.
//  Copyright © 2020 Bindu Maharudrappa. All rights reserved.
//

import UIKit

protocol WeatherCellDelegate {
    func didTapButtonInCell(_ cell: WeatherCell)
}

class WeatherCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    var delegate: WeatherCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBAction func lineChartPressed(_ sender: UIButton) {
        delegate?.didTapButtonInCell(self)               // when chart button pressed delegate perform action
    }
}
