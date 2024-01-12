import SwiftUI
import Foundation

extension Date {
    func monthName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // format for full month name
        return dateFormatter.string(from: self)
    }
    
    func weekdayName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // format for full weekday name
        return dateFormatter.string(from: self)
    }
    
    func year() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy" // format for full year
        return dateFormatter.string(from: self)
    }
    
    func isWeekend() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: self)
        if let weekday = components.weekday {
            // 1 = Sunday, 7 = Saturday in the Gregorian calendar
            let isWeekend = weekday == 1 || weekday == 7
            print("Is weekend: \(isWeekend)") // Debugging line
            return isWeekend
        }
        return false
    }
    
}



