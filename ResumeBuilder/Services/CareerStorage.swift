import Foundation

final class CareerStorage {
    static let shared = CareerStorage()

    private let defaults = UserDefaults.standard
    private let achievementsKey = "careerToolkitAchievements"
    private let applicationsKey = "careerToolkitApplications"

    private init() {}

    func loadAchievements() -> [CareerAchievement] {
        (load([CareerAchievement].self, key: achievementsKey) ?? [])
            .sorted { $0.createdAt > $1.createdAt }
    }

    func saveAchievement(_ achievement: CareerAchievement) {
        var achievements = loadAchievements()
        if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
            achievements[index] = achievement
        } else {
            achievements.append(achievement)
        }
        save(achievements, key: achievementsKey)
    }

    func deleteAchievement(id: UUID) {
        save(loadAchievements().filter { $0.id != id }, key: achievementsKey)
    }

    func loadApplications() -> [JobApplication] {
        (load([JobApplication].self, key: applicationsKey) ?? [])
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    func saveApplication(_ application: JobApplication) {
        var updated = application
        updated.updatedAt = Date()

        var applications = loadApplications()
        if let index = applications.firstIndex(where: { $0.id == updated.id }) {
            applications[index] = updated
        } else {
            applications.append(updated)
        }
        save(applications, key: applicationsKey)
    }

    func deleteApplication(id: UUID) {
        save(loadApplications().filter { $0.id != id }, key: applicationsKey)
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key),
              let value = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        return value
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }
}
