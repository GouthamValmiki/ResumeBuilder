import Foundation

enum CareerToolkitService {
    static func match(resume: Resume, jobDescription: String) -> JobMatchReport {
        let jobKeywords = rankedKeywords(in: jobDescription, limit: 28)
        let resumeWords = Set(words(in: resumeText(resume)))
        let matched = jobKeywords.filter { resumeWords.contains($0) }
        let missing = jobKeywords.filter { !resumeWords.contains($0) }
        let score = jobKeywords.isEmpty ? 0 : Int(round(Double(matched.count) / Double(jobKeywords.count) * 100))

        var suggestions: [String] = []
        if !missing.isEmpty {
            suggestions.append("Add relevant missing terms naturally: \(missing.prefix(6).joined(separator: ", ")).")
        }
        if resume.skills.count < 8 {
            suggestions.append("Strengthen the Skills section with exact tools and methods from this job.")
        }
        if !containsMetric(in: resumeText(resume)) {
            suggestions.append("Add measurable outcomes such as percentages, users, time saved, revenue, or volume.")
        }
        if !resume.personalInfo.summary.lowercased().contains(anyOf: jobKeywords.prefix(4)) {
            suggestions.append("Tailor the professional summary toward the role's top responsibilities.")
        }
        if suggestions.isEmpty {
            suggestions.append("The match is strong. Review wording and keep only keywords you can confidently explain.")
        }

        return JobMatchReport(
            score: min(100, max(0, score)),
            matchedKeywords: matched,
            missingKeywords: missing,
            suggestions: suggestions
        )
    }

    static func translateExperience(title: String, source: String) -> [String] {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanSource = source.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanSource.isEmpty else { return [] }

        let fragments = cleanSource
            .components(separatedBy: CharacterSet(charactersIn: ".\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let focus = fragments.first ?? cleanSource
        let role = cleanTitle.isEmpty ? "project" : cleanTitle.lowercased()
        let actionVerb = suggestedVerb(for: cleanSource)

        return [
            "\(actionVerb) \(focus.lowercasedFirst), applying practical skills to deliver a clear outcome.",
            "Collaborated with others during the \(role) to solve problems, communicate progress, and complete key deliverables.",
            "Improved the \(role) by documenting the process and measuring impact with a result such as time saved, quality, users, or completion rate."
        ]
    }

    static func buildSTAR(from achievement: CareerAchievement) -> STARStory {
        STARStory(
            situation: achievement.context.isBlank
                ? "Describe the challenge, team, class, project, or workplace context."
                : achievement.context,
            task: achievement.title.isBlank
                ? "Explain the goal you were responsible for."
                : "Your goal was to \(achievement.title.lowercasedFirst).",
            action: achievement.action.isBlank
                ? "Describe the specific steps you personally took and the skills you used."
                : achievement.action,
            result: achievement.result.isBlank
                ? "Finish with a measurable result, lesson, or positive outcome."
                : achievement.result
        )
    }

    static func buildSTAR(from text: String) -> STARStory {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return STARStory(
            situation: "Set the scene: when and where did this happen, and what challenge existed?",
            task: "Clarify your responsibility or the goal you needed to achieve.",
            action: clean.isEmpty ? "Describe the steps you personally took." : clean,
            result: "End with the result. Add a number, feedback, lesson, or business/student impact."
        )
    }

    private static func resumeText(_ resume: Resume) -> String {
        [
            resume.title,
            resume.personalInfo.summary,
            resume.experiences.map { "\($0.jobTitle) \($0.company) \($0.description)" }.joined(separator: " "),
            resume.projects.map { "\($0.name) \($0.role) \($0.description)" }.joined(separator: " "),
            resume.educations.map { "\($0.degree) \($0.institution) \($0.details)" }.joined(separator: " "),
            resume.skills.map(\.name).joined(separator: " ")
        ].joined(separator: " ")
    }

    private static func rankedKeywords(in text: String, limit: Int) -> [String] {
        var frequencies: [String: Int] = [:]
        for word in words(in: text) where !ignoredWords.contains(word) {
            frequencies[word, default: 0] += 1
        }
        return frequencies
            .sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .prefix(limit)
            .map(\.key)
    }

    private static func words(in text: String) -> [String] {
        text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 3 }
    }

    private static func containsMetric(in text: String) -> Bool {
        text.range(of: #"(\d+[%+]?|\$\d+|\d+x)"#, options: .regularExpression) != nil
    }

    private static func suggestedVerb(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("team") || lower.contains("club") { return "Collaborated on" }
        if lower.contains("build") || lower.contains("develop") || lower.contains("code") { return "Built" }
        if lower.contains("research") || lower.contains("analy") { return "Analyzed" }
        if lower.contains("lead") || lower.contains("manage") { return "Led" }
        if lower.contains("design") { return "Designed" }
        return "Completed"
    }

    private static let ignoredWords: Set<String> = [
        "and", "the", "for", "with", "from", "that", "this", "you", "your", "our",
        "are", "will", "have", "has", "job", "role", "work", "team", "years", "using",
        "who", "but", "not", "all", "can", "their", "they", "about", "into", "skills"
    ]
}

private extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var lowercasedFirst: String {
        guard let first else { return self }
        return first.lowercased() + dropFirst()
    }

    func contains<S: Sequence>(anyOf values: S) -> Bool where S.Element == String {
        let lower = lowercased()
        return values.contains { lower.contains($0.lowercased()) }
    }
}
