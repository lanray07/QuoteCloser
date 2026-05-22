import Foundation
import SwiftData

@Model
final class Proposal: Identifiable {
    @Attribute(.unique) var id: UUID
    var quoteId: UUID?
    var title: String
    var content: String
    var pdfLocalURLString: String?
    var createdAt: Date

    var quote: Quote?

    init(
        id: UUID = UUID(),
        quote: Quote? = nil,
        title: String = "Proposal",
        content: String = "",
        pdfLocalURL: URL? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.quote = quote
        self.quoteId = quote?.id
        self.title = title
        self.content = content
        self.pdfLocalURLString = pdfLocalURL?.absoluteString
        self.createdAt = createdAt
    }

    var pdfLocalURL: URL? {
        get {
            guard let pdfLocalURLString else { return nil }
            return URL(string: pdfLocalURLString)
        }
        set {
            pdfLocalURLString = newValue?.absoluteString
        }
    }
}
