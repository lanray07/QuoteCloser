import Foundation
import Observation

@MainActor
@Observable
final class VoiceToQuoteViewModel {
    var summary: String = ""
    var isLoading = false
    var errorMessage: String?

    func summarize(
        transcript: String,
        profile: BusinessProfile?,
        aiService: any AIService
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = AIRequestContext(
                businessType: profile?.businessType ?? .localServiceBusiness,
                serviceType: "",
                clientName: "",
                clientNotes: "",
                quoteDetails: "",
                tone: .friendly
            )
            summary = try await aiService.summarizeVoiceNotes(transcript, request: request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
