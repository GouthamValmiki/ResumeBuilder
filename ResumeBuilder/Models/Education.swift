import Foundation

struct Education: Codable, Identifiable, Equatable {
    var id: UUID
    var institution: String
    var degree: String
    var location: String
    var startDate: String
    var endDate: String
    var details: String

    init(
        id: UUID = UUID(),
        institution: String = "",
        degree: String = "",
        location: String = "",
        startDate: String = "",
        endDate: String = "",
        details: String = ""
    ) {
        self.id = id
        self.institution = institution
        self.degree = degree
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.details = details
    }

    var dateRange: String {
        if startDate.isEmpty && endDate.isEmpty { return "" }
        if startDate.isEmpty { return endDate }
        if endDate.isEmpty { return startDate }
        return "\(startDate) – \(endDate)"
    }
}
