import Foundation

struct SunData: Codable {
    let results: SunTimes
}

struct SunTimes: Codable {
    let sunrise: String
    let sunset: String
}

func fetchSunData(latitude: Double, longitude: Double, completion: @escaping (SunTimes?) -> Void) {
    let urlString = "https://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&formatted=0"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print(error!)
            completion(nil)
            return
        }
        let sunData = try? JSONDecoder().decode(SunData.self, from: data)
        completion(sunData?.results)
    }.resume()
}
