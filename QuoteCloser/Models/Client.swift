import Foundation
import SwiftData

@Model
final class Client: Identifiable {
    @Attribute(.unique) var id: UUID
    var name: String
    var phone: String
    var email: String
    var address: String
    var serviceRequested: String
    var budgetRange: String
    var urgencyRaw: String
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Quote.client)
    var quotes: [Quote] = []

    init(
        id: UUID = UUID(),
        name: String = "",
        phone: String = "",
        email: String = "",
        address: String = "",
        serviceRequested: String = "",
        budgetRange: String = "",
        urgency: LeadUrgency = .standard,
        notes: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        self.address = address
        self.serviceRequested = serviceRequested
        self.budgetRange = budgetRange
        self.urgencyRaw = urgency.rawValue
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var urgency: LeadUrgency {
        get { LeadUrgency(rawValue: urgencyRaw) ?? .standard }
        set {
            urgencyRaw = newValue.rawValue
            updatedAt = .now
        }
    }
}
