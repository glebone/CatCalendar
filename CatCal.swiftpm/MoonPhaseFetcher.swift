import Foundation
import SwiftUI

func calculateMoonPhase(for date: Date) -> String {
    let referenceNewMoonDate = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 6))!
    let lunarCycle = 29.53059 // Average length of the lunar cycle in days
    let secondsPerDay = 86400.0
    
    let interval = date.timeIntervalSince(referenceNewMoonDate)
    let daysSinceNewMoon = interval / secondsPerDay
    
    let lunations = daysSinceNewMoon / lunarCycle
    let positionInCycle = lunations.truncatingRemainder(dividingBy: 1) * lunarCycle
    
    
    // Determine moon phase based on position in lunar cycle
    switch positionInCycle {
    case 0..<1.84566:
        return "New Moon"
    case 1.84566..<5.53699:
        return "Waxing Crescent"
    case 5.53699..<9.22831:
        return "First Quarter"
    case 9.22831..<12.91963:
        return "Waxing Gibbous"
    case 12.91963..<16.61096:
        return "Full Moon"
    case 16.61096..<20.30228:
        return "Waning Gibbous"
    case 20.30228..<23.99361:
        return "Last Quarter"
    case 23.99361..<27.68493:
        return "Waning Crescent"
    default:
        return "New Moon"
    }
}

func getMoonImage(phase: String) -> Image {
    
    switch phase {
    case "New Moon":
       return  Image(systemName: "moonphase.new.moon")
    case "Waxing Crescent":
       return Image(systemName: "moonphase.waxing.crescent")
    case "First Quarter":
       return Image(systemName: "moonphase.first.quarter")
    case "Waxing Gibbous":
       return Image(systemName: "moonphase.waxing.gibbous")
    case "Full Moon":
      return Image(systemName: "moonphase.full.moon")
    case "Waning Gibbous":
      return Image(systemName: "moonphase.waning.gibbous")
    case "Last Quarter":
      return Image(systemName: "moonphase.last.quarter")
    case "Waning Crescent":
      return Image(systemName: "moonphase.waning.crescent")
    default:
      return Image(systemName: "moon.stars.fill")
        
    }
    
}

// Example usage


