import Foundation

struct Project: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var role: String
    var link: String
    var startDate: String
    var endDate: String
    var description: String

    init(
        id: UUID = UUID(),
        name: String = "",
        role: String = "",
        link: String = "",
        startDate: String = "",
        endDate: String = "",
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.link = link
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }

    var dateRange: String {
        if startDate.isEmpty && endDate.isEmpty { return "" }
        if startDate.isEmpty { return endDate }
        if endDate.isEmpty { return startDate }
        return "\(startDate) – \(endDate)"
    }

    var sortDateValue: Date {
        let cleaned = startDate.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty {
            return Date.distantFuture
        }
        
        // Extract first 4-digit number starting with 19 or 20 representing a year
        let range = NSRange(location: 0, length: cleaned.utf16.count)
        if let regex = try? NSRegularExpression(pattern: "\\b(19|20)\\d{2}\\b"),
           let match = regex.firstMatch(in: cleaned, options: [], range: range) {
            let nsRange = match.range(at: 0)
            if let swiftRange = Range(nsRange, in: cleaned),
               let yearVal = Int(cleaned[swiftRange]) {
                var comps = DateComponents()
                comps.year = yearVal
                comps.month = 1
                comps.day = 1
                if let date = Calendar.current.date(from: comps) {
                    return date
                }
            }
        }
        
        let formatters = ["MMM yyyy", "MMMM yyyy", "MM/yyyy", "yyyy-MM", "yyyy"].map { fmt -> DateFormatter in
            let df = DateFormatter()
            df.dateFormat = fmt
            df.locale = Locale(identifier: "en_US_POSIX")
            return df
        }
        
        for df in formatters {
            if let date = df.date(from: cleaned) {
                return date
            }
        }
        
        return Date.distantFuture
    }
}
