/*
 CAT Soft(c) Swift Tear-off calendar 
 -------------------------------------------
 glebone@gmail.com || 11 January 2024
 
 */

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    
    @State private var isFlipped = false
    @State private var flipDegrees = 0.0
    @State private var mainDate: Date = Date()
       
    var body: some View {
           VStack {
               ZStack {
                   FrontSideView(mainDate: $mainDate)
                       .opacity(isFlipped ? 0 : 1)
                   
                   BackSideView(mainDate: $mainDate)
                       .opacity(isFlipped ? 1 : 0)
                       .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
               }
               .rotation3DEffect(.degrees(flipDegrees), axis: (x: 0, y: 1, z: 0))
               .onTapGesture {
                   withAnimation {
                       flipDegrees += 180
                       isFlipped.toggle()
                   }
               }
           }
       }
   
}

struct FrontSideView: View {
    @State private var sunriseTime = ""
    @State private var sunsetTime = ""
    @State private var moonPhase = ""
    @State private var itEvents: String = ""
    @State private var currentDate = Date()
    @Binding var mainDate: Date
    
    
    var body: some View {

         VStack {
            // Row for the day number
            Text(Date().year())
                .padding(.top)
                .font(.title)
            HStack {
                Text("\(currentDate.monthName()), ")
                    .font(.title)
                Text(currentDate.weekdayName())
                    .font(.title)
                    .foregroundColor(currentDate.isWeekend() ? .red : .primary)
            }
            HStack {
                Button(action: {
                    self.changeDate(by: -1)
                }) {
                    Image(systemName: "arrow.left")
                }
                
                Text("\(Calendar.current.component(.day, from: currentDate))")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(currentDate.isWeekend() ? .red : .primary)
                
                Button(action: {
                    self.changeDate(by: 1)
                }) {
                    Image(systemName: "arrow.right")
                }
            }
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
                
                Text(getMoonImage(phase: calculateMoonPhase(for: Date())))
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
          
            self.updateViewForDate()
        }
        
        
    }
    
    private func changeDate(by days: Int) {
        print("%%%%%%%%%%%%%%")
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) {
            currentDate = newDate
            mainDate = newDate
            updateViewForDate()
        }
    }
    
    private func updateViewForDate() {
        print("ˆˆˆˆˆˆˆˆˆˆˆˆˆˆˆˆˆ")
        fetchSunData(latitude: 49.4413, longitude: 32.0643, cdate: currentDate) { sunTimes in
            if let sunTimes = sunTimes {
                DispatchQueue.main.async {
                    print(sunTimes.sunrise)
                    sunriseTime = formatTime(isoDate: sunTimes.sunrise)
                    sunsetTime = formatTime(isoDate: sunTimes.sunset)
                }
            }
        }
        
        fetchOpenAIResponse(cdate: currentDate) { eventsText in
            itEvents = eventsText
        }
        // Update your view based on the new date
        // For example, recalculate sunrise and sunset times
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
