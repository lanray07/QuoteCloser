import Foundation
import SwiftData

@Model
final class FollowUpMessage: Identifiable {
    @Attribute(.unique) var id: UUID
    var quoteId: UUID?
    var typeRaw: String
    var toneRaw: String
    var content: String
    var createdAt: Date

    var quote: Quote?

    init(
        id: UUID = UUID(),
        quote: Quote? = nil,
        type: FollowUpKind = .sms,
        tone: ToneOption = .friendly,
        content: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.quote = quote
        self.quoteId = quote?.id
        self.typeRaw = type.rawValue
        self.toneRaw = tone.rawValue
        self.content = content
        self.createdAt = createdAt
    }

    var type: FollowUpKind {
        get { FollowUpKind(rawValue: typeRaw) ?? .sms }
        set { typeRaw = newValue.rawValue }
    }

    var tone: ToneOption {
        get { ToneOption(rawValue: toneRaw) ?? .friendly }
        set { toneRaw = newValue.rawValue }
    }
}
