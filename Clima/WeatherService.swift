import Foundation
import CoreLocation

protocol WeatherServiceDelegate {
    func didUpdateWeather(_ weatherService: WeatherService, weather: WeatherModel)
    func didFailWithError(_ weatherService: WeatherService, error: Error)
}

struct WeatherService {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=31ffd6fb6474f838a2bdc0fc22c45e0d&units=metric"
    var delegate: WeatherServiceDelegate?

    func fetchWeather(for cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        performRequest(with: urlString)
    }

    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }

    private func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(self, error: error!)
                    return
                }

                if let safeData = data, let weather = parseJSON(safeData) {
                    delegate?.didUpdateWeather(self, weather: weather)
                }
            }
            task.resume()
        }
    }

    private func parseJSON(_ weatherData: Data) -> WeatherModel? {
        do {
            let decodedData = try JSONDecoder().decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let name = decodedData.name
            return WeatherModel(conditionId: id, cityName: name, temperature: temperature)
        } catch {
            delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}
