//
//  WeatherViewController.swift
//  Weather Forecast
//
//  Created by Bindu Maharudrappa on 29.08.20.
//  Copyright © 2020 Bindu Maharudrappa. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import Charts
import TinyConstraints

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var temperatureUnitSwitch: UISwitch!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var mainViewBG: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    var weatherData: WeatherModel?
    var date: String?
    
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    var viewOverlay: UIView = UIView()
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var weatherItemArray = [WeatherItem]()
    var lineChartArray = [WeatherItem]()
    var yValues: [ChartDataEntry] = []
    let cellName = "WeatherCell"
    let cellReuseIdetifier = "ReusableCell"
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        chartView.backgroundColor = .systemBlue
        chartView.rightAxis.enabled = false
        chartView.xAxis.labelPosition = .bottom
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
        searchTextField.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellReuseIdetifier)
        
        let mytapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.view.addGestureRecognizer(mytapGestureRecognizer)
        
        updateUI()
    }
    
    func updateUI() {
        viewOverlay = UIView(frame: UIScreen.main.bounds)
        viewOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        viewOverlay.center = view.center
        
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: activityIndicatorView.bounds.size.width, height: activityIndicatorView.bounds.size.height)
        activityIndicatorView.center = viewOverlay.center
        
        viewOverlay.addSubview(activityIndicatorView)
        view.addSubview(viewOverlay)
        activityIndicatorView.startAnimating()
        
        view.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        lineChartView.isHidden = true
        
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.view.isHidden = false
            self.activityIndicatorView.startAnimating()
            self.locationManager.requestLocation()
        }
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        if sender.isOn {
            temperatureLabel.text = weatherData?.temperatureFahrenheit
        } else {
            temperatureLabel.text = weatherData?.temperatureCelsius
        }
        self.tableView.reloadData()
    }
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        if !lineChartView.isHidden {
            lineChartView.isHidden = true
        }
        else {
            lineChartView.isHidden = true
        }
    }
    
    
    //MARK: - Coredata model manupulation methods
    func saveItems() {
        do{
            try managedContext.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func loadItems() {
        let request: NSFetchRequest<WeatherItem> = WeatherItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "cityName", ascending: true)]
        do{
            weatherItemArray = try managedContext.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    //MARK: - LineChart methods
    func setData() {
        let set1 = LineChartDataSet(entries: yValues, label: "Time")
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        lineChartView.data = data
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            return true
        } else {
            searchTextField.placeholder = "Type cityname"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        //use searchTextField.text to get the weather for that city
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city.trimmingCharacters(in: .whitespaces))
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager , weather: WeatherModel) {
        let item = WeatherItem(context: self.managedContext)
        weatherData = weather
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        item.cityName = weather.cityName
        item.temperatureF =  "\(weather.temperatureFahrenheit) °F"
        item.temperatureC =  "\(weather.temperatureCelsius) °C"
        item.date = "\(year):\(month):\(day)"
        item.time = Double(hour)
        DispatchQueue.main.async {
            if self.temperatureUnitSwitch.isOn {
                self.temperatureLabel.text = weather.temperatureFahrenheit
            } else {
                self.temperatureLabel.text = weather.temperatureCelsius
            }
            self.cityLabel.text = weather.cityName
            self.mainViewBG.backgroundColor = weather.mainViewBGColor
            self.loadItems()
            self.tableView.reloadData()
        }
        self.saveItems()
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.viewOverlay.isHidden = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//MARK: - UITableViewDataSource

extension WeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdetifier, for: indexPath) as! WeatherCell
        cell.delegate = self
        cell.cityLabel.text = weatherItemArray[indexPath.row].cityName
        cell.dateLabel.text = weatherItemArray[indexPath.row].date
        cell.timeLabel.text = String(format: " %@:00", String(weatherItemArray[indexPath.row].time).prefix(2) as CVarArg)
        if temperatureUnitSwitch.isOn {
            cell.temperatureLabel.text = weatherItemArray[indexPath.row].temperatureF
        } else {
            cell.temperatureLabel.text = weatherItemArray[indexPath.row].temperatureC
        }
        return cell
    }
}

//MARK: - WeatherCellDelegate

extension WeatherViewController: WeatherCellDelegate {
    func didTapButtonInCell(_ cell: WeatherCell) {
        let request: NSFetchRequest<WeatherItem> = WeatherItem.fetchRequest()
        request.predicate = NSPredicate(format: "cityName = %@", cell.cityLabel.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        do{
            lineChartArray = try managedContext.fetch(request)
            yValues.removeAll()
            for data in lineChartArray as [NSManagedObject] {
                let time = data.value(forKey: "time") as! Double
                let tempStr = data.value(forKey: "temperatureF") as! String
                let temperature = Double(tempStr.prefix(2))
                let lineArray =  ChartDataEntry(x: time , y: temperature!)
                yValues.append(lineArray)
            }
            print(yValues)
        } catch {
            print("Error fetching data from context \(error)")
        }
        lineChartView.isHidden = false
        self.setData()
    }
}
