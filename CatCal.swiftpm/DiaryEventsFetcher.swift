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
    let givenMonth = calendar.component(.month, from: date)

    var dayRange = 2
    var nearestEntries: [DiaryEntry] = []

    while nearestEntries.count < n {
        nearestEntries = entries.filter { entry in
            guard let entryDate = entry.date() else { return false }
            let dayDifference = abs(calendar.component(.day, from: entryDate) - givenDay)
            return calendar.component(.month, from: entryDate) == givenMonth && dayDifference <= dayRange
        }
        .sorted {
            calendar.component(.year, from: $0.date()!) < calendar.component(.year, from: $1.date()!)
        }

        if nearestEntries.count >= n || dayRange > 15 { // Avoid infinite loop
            break
        }

        dayRange += 1 // Expand the day range if not enough entries are found
    }

    let entriesText = nearestEntries.prefix(n).map { "\($0.adate): \($0.atext)" }.joined(separator: "\n\n")
    return entriesText.isEmpty ? "No matching entries found." : entriesText
}

