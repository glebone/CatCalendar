import Foundation

struct DiaryEntry: Codable {
    var adate: String
    var atext: String
    
    func date() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.date(from: adate)
    }
}

func findNearestEntries(for date: Date, numberOfRecords n: Int) -> String {
    guard let url = Bundle.main.url(forResource: "Fake_diary", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let entries = try? JSONDecoder().decode([DiaryEntry].self, from: data) else {
        return "Failed to load diary entries."
    }
    
    let calendar = Calendar.current
    let givenDay = calendar.component(.day, from: date)
    
    var dayEntries: [(DiaryEntry, Int)] = entries.compactMap { entry in
        guard let entryDate = entry.date() else { return nil }
        let dayDifference = abs(calendar.component(.day, from: entryDate) - givenDay)
        return (entry, dayDifference)
    }
    
    dayEntries.sort {
        if $0.1 != $1.1 { 
            return $0.1 < $1.1 // First, sort by the day difference
        } else {
            // If the day difference is the same, sort by year in descending order
            return calendar.component(.year, from: $0.0.date()!) > calendar.component(.year, from: $1.0.date()!)
        }
    }
    
    let nearestEntries = dayEntries.prefix(n).map { $0.0 }
    
    return nearestEntries.map { "\($0.adate): \($0.atext)" }.joined(separator: "\n")
}








// Usage example
/*let exampleDate = Date() // Replace with any Date object
let nearestDiaryTexts = findNearestEntries(for: exampleDate, numberOfRecords: 3)
print(nearestDiaryTexts)*/
