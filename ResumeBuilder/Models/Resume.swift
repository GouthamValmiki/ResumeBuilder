import Foundation

struct Resume: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var template: ResumeTemplate
    var personalInfo: PersonalInfo
    var experiences: [WorkExperience]
    var projects: [Project]
    var educations: [Education]
    var skills: [Skill]
    var sectionOrder: [ResumeSectionType]
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "My Resume",
        template: ResumeTemplate = .classic,
        personalInfo: PersonalInfo = PersonalInfo(),
        experiences: [WorkExperience] = [],
        projects: [Project] = [],
        educations: [Education] = [],
        skills: [Skill] = [],
        sectionOrder: [ResumeSectionType] = ResumeSectionType.defaultOrder,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.template = template
        self.personalInfo = personalInfo
        self.experiences = experiences
        self.projects = projects
        self.educations = educations
        self.skills = skills
        self.sectionOrder = sectionOrder
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, template, personalInfo, experiences, projects
        case educations, skills, sectionOrder, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        template = try container.decodeIfPresent(ResumeTemplate.self, forKey: .template) ?? .classic
        personalInfo = try container.decode(PersonalInfo.self, forKey: .personalInfo)
        experiences = try container.decodeIfPresent([WorkExperience].self, forKey: .experiences) ?? []
        projects = try container.decodeIfPresent([Project].self, forKey: .projects) ?? []
        educations = try container.decodeIfPresent([Education].self, forKey: .educations) ?? []
        skills = try container.decodeIfPresent([Skill].self, forKey: .skills) ?? []
        sectionOrder = try container.decodeIfPresent([ResumeSectionType].self, forKey: .sectionOrder) ?? ResumeSectionType.defaultOrder
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }

    func entryCount(for section: ResumeSectionType) -> Int {
        switch section {
        case .experience: return experiences.count
        case .projects: return projects.count
        case .education: return educations.count
        case .skills: return skills.count
        }
    }

    static func sample(template: ResumeTemplate = .classic) -> Resume {
        var resume = Resume(title: "Software Engineer Resume", template: template)
        resume.personalInfo = PersonalInfo(
            fullName: "Alex Johnson",
            email: "alex.johnson@email.com",
            phone: "+1 (555) 123-4567",
            address: "San Francisco, CA",
            linkedIn: "linkedin.com/in/alexjohnson",
            website: "alexjohnson.dev",
            summary: "Experienced software engineer with 5+ years building iOS and backend systems. Passionate about clean architecture and user-centered design."
        )
        resume.experiences = [
            WorkExperience(
                company: "TechCorp Inc.",
                jobTitle: "Senior iOS Developer",
                location: "San Francisco, CA",
                startDate: "Jan 2021",
                endDate: "Present",
                description: "Led development of flagship iOS app with 2M+ users.\nImplemented offline-first architecture reducing crash rate by 40%.\nMentored junior developers and conducted code reviews."
            )
        ]
        resume.projects = [
            Project(
                name: "Resume Builder App",
                role: "Lead Developer",
                link: "github.com/alex/resume-builder",
                startDate: "2024",
                endDate: "Present",
                description: "Built a UIKit resume builder with PDF export.\nSupports multiple templates and section reordering."
            )
        ]
        resume.educations = [
            Education(
                institution: "University of California",
                degree: "B.S. Computer Science",
                location: "Berkeley, CA",
                startDate: "2014",
                endDate: "2018",
                details: "GPA: 3.8/4.0\nDean's List, ACM Programming Contest finalist"
            )
        ]
        resume.skills = [
            Skill(name: "Swift", category: "Languages"),
            Skill(name: "UIKit", category: "Frameworks"),
            Skill(name: "Git", category: "Tools")
        ]
        return resume
    }
}
