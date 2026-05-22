import Foundation
import SwiftData

@Model
final class QuotePhoto: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var localImageURL: URL?
    var caption: String
    var createdAt: Date

    var quote: Quote?

    init(
        id: UUID = UUID(),
        quote: Quote? = nil,
        imageData: Data? = nil,
        localImageURL: URL? = nil,
        caption: String = "",
        createdAt: Date = .now
    ) {
        self.id = id
        self.quote = quote
        self.imageData = imageData
        self.localImageURL = localImageURL
        self.caption = caption
        self.createdAt = createdAt
    }
}
