//
//  ViewController.swift
//  Lab8-Weather-App
//
//  Created by Shaik Mathar Syed on 11/11/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // Setting Up Outlets
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageLabel: UIImageView!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!

    // Create a LocationManager
    let userLocationManager = CLLocationManager()

    // Function to Download the Image from the API response
    func getClimateImage(imageURL: URL, weatherImageView: UIImageView) {
        let task = URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async { // Make sure you're on the main thread here
                weatherImageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if CLLocationManager.locationServicesEnabled() {
            userLocationManager.delegate = self
            userLocationManager.desiredAccuracy = kCLLocationAccuracyBest
            userLocationManager.requestWhenInUseAuthorization()
            userLocationManager.startUpdatingLocation()
            userLocationManager.distanceFilter = 8
        }
    }

    // Function call and show the response from the API
    func getWeatherApi(lat: String, long: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=91ae61a7418549d33a28664b65bb7fd7&units=metric")
        else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            if let data = data {
                let jsonDecoder = JSONDecoder()
                do {
                    let jsonData = try jsonDecoder.decode(Weather.self, from: data)

                    let imageURL = URL(string: "https://openweathermap.org/img/wn/" + jsonData.weather[0].icon + "@2x.png")
                        Task { @MainActor in
                            self.locationLabel.text = jsonData.name
                            self.weatherDescriptionLabel.text = String(jsonData.weather[0].main)
                            self.temperatureLabel.text = String(format: "%.1f", jsonData.main.temp) + " º"
                            self.humidityLabel.text = "Humidity: " + String(jsonData.main.humidity) + "%"
                            self.windLabel.text = "Wind: " + String(format: "%.2f", jsonData.wind.speed*3.6) + " km/h"
                            self.getClimateImage(imageURL: imageURL!, weatherImageView: self.weatherImageLabel)
                        }
                    } catch {
                        print("Error")
                    }
                }
            }
            task.resume()
        }

    // Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        getWeatherApi(lat: String(locValue.latitude), long: String(locValue.longitude))
    }
}
