/*
 CAT Soft(c) Swift Tear-off calendar 
 -------------------------------------------
 glebone@gmail.com || 11 January 2024
 
 */

import SwiftUI
import WeatherKit
import CoreLocation

enum SelectedButton {
    case gpt, wiki, diary
}

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
    @State private var wikiEvents: String = ""
    @State private var diaryEvents: String = ""
    @State private var currentDate = Date()
    @State private var showingDatePicker = false
    @Binding var mainDate: Date
    @State private var selectedButton: SelectedButton = .gpt
    
    
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
                
                Button(action: {
                                   self.showingDatePicker.toggle()
                               }) {
                                   Text("\(Calendar.current.component(.day, from: currentDate))")
                                       .font(.system(size: 60, weight: .bold))
                                       .foregroundColor(currentDate.isWeekend() ? .red : .primary)
                               }
                
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
                    Image(systemName: "sunrise")
                    Text(sunriseTime)
                        .font(.title)
                }
                
                Spacer() // Spacer for pushing content to the edges
                
                // VStack for Calendar Icon (Centered)
                VStack {
                
                    HStack {
                                           // Calendar Icon (Shown if it's today's date)
                                           if Calendar.current.isDateInToday(mainDate) {
                                               Image(systemName: "calendar.badge.checkmark.rtl")
                                           }

                                           // Drawing Icon (Shown if there is a drawing file for the date)
                                           if doesDrawingExist(for: mainDate) {
                                               Image(systemName: "square.and.pencil")
                                           }
                                          if doesTextExist(for: mainDate) {
                                              Image(systemName: "text.bubble")
                            
                                          }
                                       }
                                       .frame(maxWidth: .infinity)
                    
                    
                    
                    
                }
                
                Spacer() // Another Spacer
                
                // VStack for Sunset
                VStack {
                    Image(systemName: "sunset")
                        .font(.headline)
                    Text(sunsetTime)
                        .font(.title)
                }
            }
            .padding()
            HStack {
                
                Text(getMoonImage(phase: calculateMoonPhase(for: mainDate)))
                Text(calculateMoonPhase(for: mainDate))
            }
               
            ScrollView {
                if selectedButton == .gpt {
                       Text(itEvents)
                           .padding()
                   } else if selectedButton == .wiki {
                       Text(wikiEvents)
                           .padding()
                   }
            }
            .frame(maxHeight: .infinity) // Set a maximum height for the scroll view
            Spacer()
             
             HStack {
                 // GPT Button
                 Button("GPT") {
                     selectedButton = .gpt
                 }
                 .buttonStyle(SelectableButtonStyle(isSelected: selectedButton == .gpt))
                 
                 Spacer()
                 
                 // Wiki Button
                 Button("Wiki") {
                     selectedButton = .wiki
                 }
                 .buttonStyle(SelectableButtonStyle(isSelected: selectedButton == .wiki))
                 
                 Spacer()
                 
                 // Diary Button
                 Button("Diary") {
                     selectedButton = .diary
                 }
                 .buttonStyle(SelectableButtonStyle(isSelected: selectedButton == .diary))
             }
             .padding()
            
        }
        
        .padding()
        .background(
            Color(red: 0.98, green: 0.95, blue: 0.90)
                .edgesIgnoringSafeArea(.all)  // This makes the background extend to the whole screen including the safe area

        )
        
        .sheet(isPresented: $showingDatePicker) {
            NavigationView {
                DatePicker("Select a Date", selection: $currentDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .navigationTitle("Choose Date")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                self.showingDatePicker = false
                            }
                        }
                    }
                    .padding()
                    .onDisappear {                                   // This closure is called when the NavigationView is about to disappear
                        print("Selected date: \(currentDate)")
                        self.mainDate = currentDate
                }
                    
            }
        }
        
        
        .onAppear {
            // Replace with actual latitude and longitude
            self.updateViewForDate()
            print(self.isRunningOnCatalyst())
        }
        
        
    }
    
    
    func doesDrawingExist(for date: Date) -> Bool {
        let formattedDate = formattedDateString(from: date)
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(formattedDate).data")

        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func doesTextExist(for date: Date) -> Bool {
        let formattedDate = formattedDateString(from: date)
        return UserDefaults.standard.object(forKey: formattedDate) != nil
    }

    
    func formattedDateString(from date: Date) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyyMMdd"
           return formatter.string(from: date)
       }
    
    func isRunningOnCatalyst() -> Bool {
        #if targetEnvironment(macCatalyst)
            return true
        #else 
            return false
        #endif
    }

    
    
    private func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: currentDate) {
            currentDate = newDate
            mainDate = newDate
            updateViewForDate()
        }
    }
    
    private func updateViewForDate() {
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
        
        getWikipediaEvents(forDate: currentDate) { wikiText in
            wikiEvents = wikiText
        }
        
        diaryEvents = findNearestEntries(for: currentDate, numberOfRecords: 11)
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print(diaryEvents)
        
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

struct SelectableButtonStyle: ButtonStyle {
    var isSelected: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(isSelected ? Color.blue : Color.gray)
            .foregroundColor(Color.white)
            .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
