//
//  WeatherTableViewCell.swift
//  StreamDemo
//
//  Created by James Langdon on 12/5/19.
//  Copyright © 2019 corporatelangdon. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet var boatImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(with viewModel: WeatherViewModel) {
        self.boatImageView.image = viewModel.boatImage
        self.cityNameLabel.text = viewModel.cityName
        self.temperatureLabel.text = viewModel.displayableTemperature
    }

}
