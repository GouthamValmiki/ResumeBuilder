import Foundation

enum ATSCheckStatus {
    case passed
    case warning
    case failed
}

struct ATSCheckItem {
    let title: String
    let detail: String
    let points: Int
    let maxPoints: Int
    let status: ATSCheckStatus
}

struct ATSCheckReport {
    let score: Int
    let rating: String
    let summary: String
    let passedChecks: [ATSCheckItem]
    let improvementChecks: [ATSCheckItem]
    let keywordSuggestions: [String]
}

enum ATSCheckerService {
    static func analyze(_ resume: Resume) -> ATSCheckReport {
        var items: [ATSCheckItem] = []

        items.append(contactCheck(resume.personalInfo))
        items.append(summaryCheck(resume.personalInfo.summary))
        items.append(skillsCheck(resume.skills))
        items.append(experienceCheck(resume.experiences))
        items.append(impactCheck(resume))
        items.append(educationCheck(resume.educations))
        items.append(projectsCheck(resume.projects))
        items.append(sectionCheck(resume))
        items.append(titleCheck(resume.title))
        items.append(keywordCheck(resume))

        let totalPoints = items.reduce(0) { $0 + $1.points }
        let totalMaxPoints = max(items.reduce(0) { $0 + $1.maxPoints }, 1)
        let score = min(100, max(0, Int(round(Double(totalPoints) / Double(totalMaxPoints) * 100))))
        let improvements = items.filter { $0.status != .passed }
        let passed = items.filter { $0.status == .passed }

        return ATSCheckReport(
            score: score,
            rating: rating(for: score),
            summary: summary(for: score, improvementCount: improvements.count),
            passedChecks: passed,
            improvementChecks: improvements,
            keywordSuggestions: keywordSuggestions(for: resume, score: score)
        )
    }

    private static func contactCheck(_ info: PersonalInfo) -> ATSCheckItem {
        var points = 0
        var missing: [String] = []

        if !info.fullName.trimmed.isEmpty { points += 3 } else { missing.append("full name") }
        if isLikelyEmail(info.email) { points += 4 } else { missing.append("valid email") }
        if digitCount(in: info.phone) >= 10 { points += 4 } else { missing.append("phone number") }
        if !info.address.trimmed.isEmpty { points += 2 } else { missing.append("location") }
        if !info.linkedIn.trimmed.isEmpty || !info.website.trimmed.isEmpty { points += 2 }

        if missing.isEmpty {
            return ATSCheckItem(
                title: "Contact details are ATS ready",
                detail: "Name, email, phone, and location are available for recruiter parsing.",
                points: 15,
                maxPoints: 15,
                status: .passed
            )
        }

        return ATSCheckItem(
            title: "Complete the contact section",
            detail: "Add \(missing.joined(separator: ", ")). A LinkedIn or portfolio link can also improve recruiter follow-up.",
            points: points,
            maxPoints: 15,
            status: points >= 10 ? .warning : .failed
        )
    }

    private static func summaryCheck(_ summary: String) -> ATSCheckItem {
        let words = wordCount(in: summary)
        var points = 0

        if words >= 25 { points += 6 }
        if (35...95).contains(words) { points += 3 }
        if containsAny(summary, terms: actionVerbs + measurableTerms) { points += 3 }

        if points >= 10 {
            return ATSCheckItem(
                title: "Professional summary is strong",
                detail: "The summary has enough context and includes recruiter-friendly action language.",
                points: points,
                maxPoints: 12,
                status: .passed
            )
        }

        let detail = words == 0
            ? "Add a 3-4 line summary with target role, years or scope, core skills, and one measurable result."
            : "Make the summary 35-95 words and include target role keywords plus one clear outcome."

        return ATSCheckItem(
            title: "Improve the professional summary",
            detail: detail,
            points: points,
            maxPoints: 12,
            status: points >= 6 ? .warning : .failed
        )
    }

    private static func skillsCheck(_ skills: [Skill]) -> ATSCheckItem {
        let filledSkills = skills.filter { !$0.name.trimmed.isEmpty }
        let categories = Set(filledSkills.map { $0.category.trimmed.lowercased() }.filter { !$0.isEmpty })
        var points = 0

        if filledSkills.count >= 6 { points += 8 } else if filledSkills.count >= 3 { points += 4 }
        if categories.count >= 2 { points += 3 }
        if filledSkills.contains(where: { containsTechnicalSignal($0.name) }) { points += 4 }

        if points >= 12 {
            return ATSCheckItem(
                title: "Skills section is keyword friendly",
                detail: "There are enough categorized skills for ATS keyword matching.",
                points: points,
                maxPoints: 15,
                status: .passed
            )
        }

        return ATSCheckItem(
            title: "Add more targeted skills",
            detail: "Use 6-12 role-specific skills from the job description, grouped by category where possible.",
            points: points,
            maxPoints: 15,
            status: points >= 7 ? .warning : .failed
        )
    }

    private static func experienceCheck(_ experiences: [WorkExperience]) -> ATSCheckItem {
        guard !experiences.isEmpty else {
            return ATSCheckItem(
                title: "Add work experience",
                detail: "ATS systems and recruiters look for job title, company, dates, and responsibility/result bullets.",
                points: 0,
                maxPoints: 18,
                status: .failed
            )
        }

        var points = 8
        let completeEntries = experiences.filter {
            !$0.company.trimmed.isEmpty &&
            !$0.jobTitle.trimmed.isEmpty &&
            (!$0.startDate.trimmed.isEmpty || !$0.endDate.trimmed.isEmpty)
        }
        let bulletCount = experiences.reduce(0) { $0 + bulletLines(in: $1.description).count }

        if completeEntries.count == experiences.count { points += 5 }
        if bulletCount >= experiences.count * 2 { points += 5 }

        if points >= 15 {
            return ATSCheckItem(
                title: "Experience section has the right structure",
                detail: "Experience entries include titles, companies, dates, and useful bullet content.",
                points: points,
                maxPoints: 18,
                status: .passed
            )
        }

        return ATSCheckItem(
            title: "Strengthen work experience",
            detail: "Each role should include job title, company, dates, and 2-5 bullets focused on results.",
            points: points,
            maxPoints: 18,
            status: .warning
        )
    }

    private static func impactCheck(_ resume: Resume) -> ATSCheckItem {
        let achievementText = [
            resume.personalInfo.summary,
            resume.experiences.map(\.description).joined(separator: " "),
            resume.projects.map(\.description).joined(separator: " ")
        ].joined(separator: " ")

        let hasMetrics = containsMetric(in: achievementText)
        let hasActionVerbs = containsAny(achievementText, terms: actionVerbs)
        let hasBusinessTerms = containsAny(achievementText, terms: measurableTerms)

        var points = 0
        if hasMetrics { points += 6 }
        if hasActionVerbs { points += 5 }
        if hasBusinessTerms { points += 4 }

        if points >= 12 {
            return ATSCheckItem(
                title: "Impact language is recruiter friendly",
                detail: "The resume uses action verbs, measurable outcomes, or business impact terms.",
                points: points,
                maxPoints: 15,
                status: .passed
            )
        }

        return ATSCheckItem(
            title: "Add measurable achievements",
            detail: "Use bullets like \"Improved onboarding by 30%\" or \"Reduced processing time by 2 hours per week.\"",
            points: points,
            maxPoints: 15,
            status: points >= 6 ? .warning : .failed
        )
    }

    private static func educationCheck(_ educations: [Education]) -> ATSCheckItem {
        let completeEducation = educations.contains {
            !$0.institution.trimmed.isEmpty && !$0.degree.trimmed.isEmpty
        }

        return ATSCheckItem(
            title: completeEducation ? "Education is clear" : "Add education details",
            detail: completeEducation
                ? "Education includes an institution and degree for ATS parsing."
                : "Include degree, institution, and dates if they help your target role.",
            points: completeEducation ? 6 : 0,
            maxPoints: 6,
            status: completeEducation ? .passed : .warning
        )
    }

    private static func projectsCheck(_ projects: [Project]) -> ATSCheckItem {
        let usefulProjects = projects.filter {
            !$0.name.trimmed.isEmpty && wordCount(in: $0.description) >= 12
        }

        if usefulProjects.isEmpty {
            return ATSCheckItem(
                title: "Use projects for extra keywords",
                detail: "Add 1-3 projects with tools, role, links, and outcomes to improve keyword coverage.",
                points: 1,
                maxPoints: 6,
                status: .warning
            )
        }

        return ATSCheckItem(
            title: "Projects add useful keyword coverage",
            detail: "Project descriptions can help match tools, domains, and responsibilities from job posts.",
            points: projects.contains(where: { !$0.link.trimmed.isEmpty }) ? 6 : 4,
            maxPoints: 6,
            status: .passed
        )
    }

    private static func sectionCheck(_ resume: Resume) -> ATSCheckItem {
        let hasCoreSections = !resume.experiences.isEmpty && !resume.skills.isEmpty
        let usesStandardSections = Set(resume.sectionOrder) == Set(ResumeSectionType.defaultOrder)
            || resume.sectionOrder.contains(.experience)

        let points = (hasCoreSections ? 6 : 2) + (usesStandardSections ? 4 : 2)
        return ATSCheckItem(
            title: points >= 8 ? "Sections are easy to scan" : "Keep standard resume sections",
            detail: points >= 8
                ? "The resume keeps core sections that ATS systems and recruiters expect."
                : "Use clear sections like Work Experience, Skills, Education, and Projects.",
            points: points,
            maxPoints: 10,
            status: points >= 8 ? .passed : .warning
        )
    }

    private static func titleCheck(_ title: String) -> ATSCheckItem {
        let words = wordCount(in: title)
        let isSpecific = words >= 2 && !title.localizedCaseInsensitiveContains("my resume")

        return ATSCheckItem(
            title: isSpecific ? "Resume title is specific" : "Use a specific resume title",
            detail: isSpecific
                ? "A role-focused title helps organize tailored resumes."
                : "Rename it for the target role, such as \"iOS Developer Resume\" or \"Product Analyst Resume.\"",
            points: isSpecific ? 5 : 2,
            maxPoints: 5,
            status: isSpecific ? .passed : .warning
        )
    }

    private static func keywordCheck(_ resume: Resume) -> ATSCheckItem {
        let text = resumeSearchText(resume)
        let uniqueKeywords = extractedKeywords(from: text)
        let skillNames = resume.skills.map { $0.name.trimmed }.filter { !$0.isEmpty }
        var points = 0

        if uniqueKeywords.count >= 18 { points += 5 } else if uniqueKeywords.count >= 10 { points += 3 }
        if skillNames.count >= 6 { points += 4 }
        if containsAny(text, terms: skillNames) { points += 3 }

        if points >= 10 {
            return ATSCheckItem(
                title: "Keyword density looks healthy",
                detail: "The resume has a solid base of skills, tools, and role terms.",
                points: points,
                maxPoints: 12,
                status: .passed
            )
        }

        return ATSCheckItem(
            title: "Tailor keywords for each job",
            detail: "Mirror exact tools, role titles, methods, and domain words from the job description.",
            points: points,
            maxPoints: 12,
            status: points >= 6 ? .warning : .failed
        )
    }

    private static func keywordSuggestions(for resume: Resume, score: Int) -> [String] {
        var suggestions: [String] = []
        let skills = resume.skills.map { $0.name.trimmed }.filter { !$0.isEmpty }
        let titleTerms = resume.experiences.map(\.jobTitle).filter { !$0.trimmed.isEmpty }

        if !titleTerms.isEmpty {
            suggestions.append("Repeat the target title naturally: \(titleTerms.prefix(2).joined(separator: ", ")).")
        } else {
            suggestions.append("Add the target job title in the summary and most relevant experience.")
        }

        if skills.count < 8 {
            suggestions.append("Add 6-12 exact skills from the job post, including tools, frameworks, and methods.")
        } else {
            suggestions.append("Prioritize the most relevant skills near the top: \(skills.prefix(5).joined(separator: ", ")).")
        }

        if !resumeSearchText(resume).localizedCaseInsensitiveContains("certification") {
            suggestions.append("Include certifications or coursework when they match the target role.")
        }

        if score < 80 {
            suggestions.append("Add more numbers: percentages, revenue, time saved, team size, users, or volume handled.")
        }

        return suggestions
    }

    private static func rating(for score: Int) -> String {
        switch score {
        case 85...100: return "Excellent"
        case 70..<85: return "Good"
        case 50..<70: return "Needs Work"
        default: return "Incomplete"
        }
    }

    private static func summary(for score: Int, improvementCount: Int) -> String {
        if score >= 85 {
            return "This resume is well structured for ATS parsing. A final job-description keyword pass can make it sharper."
        }
        if score >= 70 {
            return "This resume has a good foundation. Fix the highlighted items to improve recruiter match quality."
        }
        if improvementCount <= 3 {
            return "A few important updates can improve ATS readability and recruiter clarity."
        }
        return "Complete the missing basics first, then tailor keywords and measurable achievements for each job."
    }

    private static func resumeSearchText(_ resume: Resume) -> String {
        [
            resume.title,
            resume.personalInfo.fullName,
            resume.personalInfo.summary,
            resume.experiences.map { [$0.jobTitle, $0.company, $0.description].joined(separator: " ") }.joined(separator: " "),
            resume.projects.map { [$0.name, $0.role, $0.description].joined(separator: " ") }.joined(separator: " "),
            resume.educations.map { [$0.degree, $0.institution, $0.details].joined(separator: " ") }.joined(separator: " "),
            resume.skills.map(\.name).joined(separator: " ")
        ].joined(separator: " ")
    }

    private static func extractedKeywords(from text: String) -> Set<String> {
        let ignored: Set<String> = [
            "and", "the", "for", "with", "from", "that", "this", "have", "has",
            "was", "were", "are", "you", "your", "resume", "project", "work"
        ]

        return Set(
            text.lowercased()
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .map { $0.trimmed }
                .filter { $0.count >= 4 && !ignored.contains($0) }
        )
    }

    private static func bulletLines(in text: String) -> [String] {
        text.components(separatedBy: .newlines)
            .map { $0.trimmed }
            .filter { !$0.isEmpty }
    }

    private static func containsAny(_ text: String, terms: [String]) -> Bool {
        let lowercased = text.lowercased()
        return terms
            .map { $0.trimmed.lowercased() }
            .filter { !$0.isEmpty }
            .contains { lowercased.contains($0) }
    }

    private static func containsTechnicalSignal(_ text: String) -> Bool {
        containsAny(
            text,
            terms: [
                "swift", "uikit", "python", "java", "react", "sql", "aws", "api",
                "figma", "excel", "analytics", "kubernetes", "docker", "salesforce"
            ]
        )
    }

    private static func containsMetric(in text: String) -> Bool {
        text.range(of: #"(\d+[%+]?|\$\d+|\d+x)"#, options: .regularExpression) != nil
    }

    private static func isLikelyEmail(_ text: String) -> Bool {
        text.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil
    }

    private static func digitCount(in text: String) -> Int {
        text.filter(\.isNumber).count
    }

    private static func wordCount(in text: String) -> Int {
        text.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.trimmed.isEmpty }
            .count
    }

    private static let actionVerbs = [
        "built", "created", "led", "owned", "managed", "improved", "reduced",
        "increased", "launched", "delivered", "designed", "implemented",
        "optimized", "automated", "migrated", "mentored", "analyzed"
    ]

    private static let measurableTerms = [
        "users", "revenue", "growth", "conversion", "retention", "latency",
        "performance", "cost", "time", "quality", "accuracy", "efficiency"
    ]
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
