import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftSoup

func getWikipediaEvents(forDate date: Date, completion: @escaping (String) -> Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM_dd"  // Format like "January_26"
    let dateString = dateFormatter.string(from: date)

    let url = URL(string: "https://en.wikipedia.org/w/api.php")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let parameters: [String: String] = [
        "action": "parse",
        "page": dateString,
        "format": "json",
        "prop": "text",
        "section": "1"
    ]

    let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
    components.queryItems = queryItems

    request.url = components.url

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data")
            return
        }

        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let parse = jsonResult["parse"] as? [String: Any],
               let text = parse["text"] as? [String: Any],
               let htmlContent = text["*"] as? String {
                
                let soup = try SwiftSoup.parse(htmlContent)
                let events = try soup.select("li").array()

                var eventsDict: [String: String] = [:]
                for event in events {
                    if let aTag = try? event.select("a").first(),
                       let year = try? aTag.attr("title"),
                       let eventText = try? event.text(),
                       let yearInt = Int(year) {
                        eventsDict[String(yearInt)] = eventText
                    }
                }

                let sortedEvents = eventsDict.sorted { Int($0.key) ?? 0 > Int($1.key) ?? 0 }
                let latest20Events = sortedEvents.prefix(20)

                // Concatenating events into a single string with new lines
                let eventsString = latest20Events.map { "\($0.value)" }.joined(separator: "\n")
                completion(eventsString)
            }
        } catch {
            print("Error parsing JSON")
        }
    }
    task.resume()
}

