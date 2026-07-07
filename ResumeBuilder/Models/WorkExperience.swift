import Foundation

struct WorkExperience: Codable, Identifiable, Equatable {
    var id: UUID
    var company: String
    var jobTitle: String
    var location: String
    var startDate: String
    var endDate: String
    var description: String

    init(
        id: UUID = UUID(),
        company: String = "",
        jobTitle: String = "",
        location: String = "",
        startDate: String = "",
        endDate: String = "",
        description: String = ""
    ) {
        self.id = id
        self.company = company
        self.jobTitle = jobTitle
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.description = description
    }

    var dateRange: String {
        let end = endDate.isEmpty ? "Present" : endDate
        if startDate.isEmpty && end.isEmpty { return "" }
        if startDate.isEmpty { return end }
        return "\(startDate) – \(end)"
    }
}
