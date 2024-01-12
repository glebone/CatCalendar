import Foundation

struct SunData: Codable {
    let results: SunTimes
}

struct SunTimes: Codable {
    let sunrise: String
    let sunset: String
}

func fetchSunData(latitude: Double, longitude: Double, cdate: Date, completion: @escaping (SunTimes?) -> Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" // Set the desired format
    let dateString = dateFormatter.string(from: cdate)
    print("Fetching sun data for \(dateString)...")
    let urlString = "https://api.sunrise-sunset.org/json?lat=\(latitude)&lng=\(longitude)&date=\(dateString)&formatted=0"
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
