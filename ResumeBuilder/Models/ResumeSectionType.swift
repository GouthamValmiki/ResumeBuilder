import Foundation

enum ResumeSectionType: String, Codable, CaseIterable {
    case experience
    case projects
    case education
    case skills

    var title: String {
        switch self {
        case .experience: return "Work Experience"
        case .projects: return "Projects"
        case .education: return "Education"
        case .skills: return "Skills"
        }
    }

    var editorTitle: String {
        switch self {
        case .experience: return "Manage Experience"
        case .projects: return "Manage Projects"
        case .education: return "Manage Education"
        case .skills: return "Manage Skills"
        }
    }

    var iconName: String {
        switch self {
        case .experience: return "briefcase"
        case .projects: return "folder"
        case .education: return "graduationcap"
        case .skills: return "star"
        }
    }

    static let defaultOrder: [ResumeSectionType] = [.experience, .projects, .education, .skills]
}
