import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class FollowUpWriterViewModel {
    var kind: FollowUpKind = .sms
    var tone: ToneOption = .friendly
    var content: String = ""
    var isLoading = false
    var errorMessage: String?

    func generate(
        quote: Quote?,
        client: Client?,
        profile: BusinessProfile?,
        aiService: any AIService
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = AIRequestContext.make(
                quote: quote,
                client: client ?? quote?.client,
                profile: profile,
                tone: tone
            )
            content = try await aiService.generateFollowUp(kind, request: request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(quote: Quote?, modelContext: ModelContext) throws {
        guard let quote, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let message = FollowUpMessage(quote: quote, type: kind, tone: tone, content: content)
        modelContext.insert(message)
        quote.followUps.append(message)
        try modelContext.save()
    }
}
