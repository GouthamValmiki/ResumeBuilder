import Foundation

struct PersonalInfo: Codable, Equatable {
    var fullName: String
    var email: String
    var phone: String
    var address: String
    var linkedIn: String
    var website: String
    var summary: String

    init(
        fullName: String = "",
        email: String = "",
        phone: String = "",
        address: String = "",
        linkedIn: String = "",
        website: String = "",
        summary: String = ""
    ) {
        self.fullName = fullName
        self.email = email
        self.phone = phone
        self.address = address
        self.linkedIn = linkedIn
        self.website = website
        self.summary = summary
    }
}
