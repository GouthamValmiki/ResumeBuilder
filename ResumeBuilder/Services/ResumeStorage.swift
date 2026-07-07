import Foundation

final class ResumeStorage {
    static let shared = ResumeStorage()

    private let fileManager = FileManager.default
    private let directoryName = "Resumes"
    private let indexFileName = "index.json"
    private let legacySampleCleanupKey = "didRemoveLegacySampleResume"

    private var storageDirectory: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(directoryName, isDirectory: true)
    }

    private init() {
        createDirectoryIfNeeded()
        removeLegacySampleIfNeeded()
    }

    private func createDirectoryIfNeeded() {
        let path = storageDirectory.path
        if !fileManager.fileExists(atPath: path) {
            try? fileManager.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        }
    }

    private func removeLegacySampleIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: legacySampleCleanupKey) else { return }

        loadAll()
            .filter(isLegacySample)
            .forEach { delete(id: $0.id) }

        UserDefaults.standard.set(true, forKey: legacySampleCleanupKey)
    }

    private func isLegacySample(_ resume: Resume) -> Bool {
        resume.title == "Software Engineer Resume" &&
        resume.personalInfo.fullName == "Alex Johnson" &&
        resume.personalInfo.email == "alex.johnson@email.com" &&
        resume.experiences.count == 1 &&
        resume.projects.count == 1 &&
        resume.educations.count == 1 &&
        resume.skills.map(\.name) == ["Swift", "UIKit", "Git"]
    }

    private func fileURL(for id: UUID) -> URL {
        storageDirectory.appendingPathComponent("\(id.uuidString).json")
    }

    func loadAll() -> [Resume] {
        createDirectoryIfNeeded()
        guard let files = try? fileManager.contentsOfDirectory(at: storageDirectory, includingPropertiesForKeys: nil) else {
            return []
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return files
            .filter { $0.pathExtension == "json" && $0.lastPathComponent != indexFileName }
            .compactMap { url -> Resume? in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(Resume.self, from: data)
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func load(id: UUID) -> Resume? {
        let url = fileURL(for: id)
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(Resume.self, from: data)
    }

    @discardableResult
    func save(_ resume: Resume) -> Resume {
        createDirectoryIfNeeded()
        var updated = resume
        updated.updatedAt = Date()

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        if let data = try? encoder.encode(updated) {
            try? data.write(to: fileURL(for: updated.id), options: .atomic)
        }
        return updated
    }

    func delete(id: UUID) {
        try? fileManager.removeItem(at: fileURL(for: id))
    }
}
