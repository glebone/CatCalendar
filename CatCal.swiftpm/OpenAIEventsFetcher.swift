import Foundation

import Foundation

func fetchOpenAIResponse(completion: @escaping (String) -> Void) {
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer TOKEN", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd"
    let currentDate = dateFormatter.string(from: Date())
    
    let prompt = "This day, \(currentDate) in tech during years, give me 3 facts"
    
    print(prompt)
    
    let requestBody = [
        "model": "gpt-3.5-turbo",
        "messages": [
            ["role": "user", "content": prompt]
        ],
        "temperature": 0.7
    ] as [String : Any]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        print("Error: Unable to encode JSON data")
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("Error: HTTP request failed")
            return
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = jsonObject["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                DispatchQueue.main.async {
                    completion(content)
                }
            }
        } catch {
            print("Error: Unable to parse JSON response")
        }
    }
    task.resume()


}
