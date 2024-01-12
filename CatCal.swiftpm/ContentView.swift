/*
 CAT Soft(c) Swift Tear-off calendar 
 -------------------------------------------
 glebone@gmail.com || 11 January 2024
 
 */

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    @State private var sunriseTime = ""
    @State private var sunsetTime = ""
    @State private var moonPhase = ""
    @State private var itEvents: String = ""
    
    var body: some View {

        VStack {
            // Row for the day number
            Text(Date().year())
                .padding(.top)
                .font(.title)
            HStack {
                Text("\(Date().monthName()), ")
                    .font(.title)
                Text(Date().weekdayName())
                    .font(.title)
                    .foregroundColor(Date().isWeekend() ? .red : .primary)
            }
            Text("\(Calendar.current.component(.day, from: Date()))")
                .font(.system(size: 60, weight: .bold)) // Large, bold font
                .foregroundColor(Date().isWeekend() ? .red : .primary)
                .padding()
            
            // Row for the sunrise and sunset times
            HStack {
                VStack {
                    Text(Image(systemName: "sunrise"))
                    Text(sunriseTime)
                        .font(.title)
                }
                Spacer()
                VStack {
                    Text(Image(systemName: "sunset"))
                        .font(.headline)
                    Text(sunsetTime)
                        .font(.title)
                }
            }
            .padding()
            HStack {
                Text(Image(systemName: "moon"))
                Text(calculateMoonPhase(for: Date())) 
            }
               
          
            
            ScrollView {
                Text(itEvents)
                    .padding()
            }
            .frame(maxHeight: .infinity) // Set a maximum height for the scroll view
            Spacer()
            
        }
        
        .padding()
        .background(
            Color(red: 0.98, green: 0.95, blue: 0.90)
                .edgesIgnoringSafeArea(.all)  // This makes the background extend to the whole screen including the safe area

        )
        
        .onAppear {
            // Replace with actual latitude and longitude
            fetchSunData(latitude: 49.4413, longitude: 32.0643) { sunTimes in
                if let sunTimes = sunTimes {
                    DispatchQueue.main.async {
                        print(sunTimes.sunrise)
                        sunriseTime = formatTime(isoDate: sunTimes.sunrise)
                        sunsetTime = formatTime(isoDate: sunTimes.sunset)
                    }
                }
            }
            
            fetchOpenAIResponse { eventsText in
                itEvents = eventsText
            }
            
        }
        
        
    }
    
    private func formatTime(isoDate: String) -> String {
        print(isoDate)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 7200) // API's reference timezone
        
        guard let date = isoFormatter.date(from: isoDate) else {
            print("Failed to parse date: \(isoDate)") // Debugging line
            return "N/A"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US_POSIX") // Consistent 24-hour format
        formatter.timeZone = TimeZone(identifier: "Europe/Kiev") // Kyiv's time zone
        
        return formatter.string(from: date)
    }
}


