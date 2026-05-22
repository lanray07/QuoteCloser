import Foundation
import SwiftData

@Model
final class UpsellSuggestion: Identifiable {
    @Attribute(.unique) var id: UUID
    var quoteId: UUID?
    var title: String
    var details: String
    var estimatedValue: Double
    var selected: Bool
    var createdAt: Date

    var quote: Quote?

    init(
        id: UUID = UUID(),
        quote: Quote? = nil,
        title: String,
        description: String,
        estimatedValue: Double,
        selected: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.quote = quote
        self.quoteId = quote?.id
        self.title = title
        self.details = description
        self.estimatedValue = estimatedValue
        self.selected = selected
        self.createdAt = createdAt
    }
}
