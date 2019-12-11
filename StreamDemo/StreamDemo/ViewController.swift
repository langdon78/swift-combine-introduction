//
//  ViewController.swift
//  StreamDemo
//
//  Created by James Langdon on 12/4/19.
//  Copyright © 2019 corporatelangdon. All rights reserved.
//

import UIKit
import Combine

struct WeatherViewModel {
    
    var boatImage: UIImage?
    var cityName: String
    var unit: String
    var temperature: Double?
    
    var displayableTemperature: String {
        guard let temp = temperature else { return "" }
        
        return "\(temp) \(unit)"
    }
    
    init(city: City, unit: WeatherApiConstants.Unit, boatImage: UIImage? = nil) {
        self.cityName = city.rawValue
        self.unit = unit.symbol
        self.boatImage = boatImage
    }
    
    mutating func fetchWeather(with weatherResponse: WeatherResponse) {
        self.temperature = weatherResponse.main.temp
    }
}

class ViewController: UIViewController {
    var weatherApi = WeatherAPI()
    var cancellable: AnyCancellable?
    
    var nextBoatStopPosition: CGFloat!
    
    var boatImageViews: [BoatImageView] = []
    var weatherViewModels: [WeatherViewModel] = [] {
        didSet {
            weatherTableView.reloadData()
        }
    }
    
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var cityPicker: UIPickerView! {
        didSet {
            cityPicker.dataSource = self
            cityPicker.delegate = self
        }
    }
    @IBOutlet weak var weatherTableView: UITableView! {
        didSet {
            weatherTableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBoatStopPosition = view.bounds.width - 80
    }
    
    @IBAction func addBoatPressed(_ sender: UIButton) {
        let boat = BoatImageView(verticalPosition: streamImageView.frame.midY)
        boatImageViews.append(boat)
        view.addSubview(boat)
        animateBoat()
    }
    
    @IBAction func fetchWeatherPressed(_ sender: UIButton) {
        let city = City.all[cityPicker.selectedRow(inComponent: 0)]
        let viewModel = WeatherViewModel(city: city, unit: .imperial, boatImage: boatImageViews.first?.image)
        releaseBoat()
        weatherViewModels.append(viewModel)
        let index = weatherViewModels.count - 1
        cancellable = weatherApi.retrieve(for: city).catch { _ in Just(WeatherResponse(name: "Turds", main: Weather(temp: 0.0))) }
            .sink { value in
                self.weatherViewModels[index].fetchWeather(with: value)
                self.weatherTableView.reloadData()
        }
        
    }
    
    func animateBoat() {

        UIView.animate(withDuration: 4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.boatImageViews.last?.frame.origin.x = self.nextBoatStopPosition
            self.nextBoatStopPosition -= 80
        }, completion: nil)
    }
    
    func releaseBoat() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.boatImageViews.first?.frame.origin.x = self.view.bounds.width + 80
        }, completion: { _ in
            if !self.boatImageViews.isEmpty { self.boatImageViews.removeFirst() }
            self.nextBoatStopPosition = self.view.bounds.width - 80
            for boat in self.boatImageViews {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                    boat.frame.origin.x = self.nextBoatStopPosition
                    self.nextBoatStopPosition -= 80
                }, completion: nil)
            }
        })
    }

}

// MARK: - PickerView DataSource/Delegate

extension ViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return City.allCases.count
    }
    
}

extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return City.all[row].rawValue
    }
    
}


// MARK: - TableView DataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell") as? WeatherTableViewCell else { return UITableViewCell() }
        cell.setUp(with: weatherViewModels[indexPath.row])
        return cell
    }
    
}
