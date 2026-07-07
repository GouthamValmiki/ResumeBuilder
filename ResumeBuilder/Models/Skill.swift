import Foundation

struct Skill: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var category: String

    init(id: UUID = UUID(), name: String = "", category: String = "General") {
        self.id = id
        self.name = name
        self.category = category
    }
}
