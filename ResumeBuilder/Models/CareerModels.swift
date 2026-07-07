import Foundation

struct CareerAchievement: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var context: String
    var action: String
    var result: String
    var skills: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        context: String = "",
        action: String = "",
        result: String = "",
        skills: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.context = context
        self.action = action
        self.result = result
        self.skills = skills
        self.createdAt = createdAt
    }
}

enum JobApplicationStatus: String, Codable, CaseIterable {
    case saved
    case applied
    case interview
    case offer
    case rejected

    var displayName: String {
        switch self {
        case .saved: return "Saved"
        case .applied: return "Applied"
        case .interview: return "Interview"
        case .offer: return "Offer"
        case .rejected: return "Closed"
        }
    }

    var iconName: String {
        switch self {
        case .saved: return "bookmark.fill"
        case .applied: return "paperplane.fill"
        case .interview: return "person.2.fill"
        case .offer: return "checkmark.seal.fill"
        case .rejected: return "archivebox.fill"
        }
    }
}

struct JobApplication: Codable, Identifiable, Equatable {
    var id: UUID
    var company: String
    var role: String
    var status: JobApplicationStatus
    var appliedDate: String
    var nextStep: String
    var notes: String
    var resumeID: UUID?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        company: String = "",
        role: String = "",
        status: JobApplicationStatus = .saved,
        appliedDate: String = "",
        nextStep: String = "",
        notes: String = "",
        resumeID: UUID? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.company = company
        self.role = role
        self.status = status
        self.appliedDate = appliedDate
        self.nextStep = nextStep
        self.notes = notes
        self.resumeID = resumeID
        self.updatedAt = updatedAt
    }
}

struct JobMatchReport {
    let score: Int
    let matchedKeywords: [String]
    let missingKeywords: [String]
    let suggestions: [String]
}

struct STARStory {
    let situation: String
    let task: String
    let action: String
    let result: String
}
