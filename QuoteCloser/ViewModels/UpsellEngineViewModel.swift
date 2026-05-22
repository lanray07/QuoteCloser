import Foundation
import Observation

@MainActor
@Observable
final class UpsellEngineViewModel {
    var businessType: BusinessType = .localServiceBusiness
    var serviceType = ""
    var clientNotes = ""
    var upsells: [UpsellDraft] = []
    var isLoading = false
    var errorMessage: String?

    func generate(aiService: any AIService) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = AIRequestContext(
                businessType: businessType,
                serviceType: serviceType,
                clientName: "",
                clientNotes: clientNotes,
                quoteDetails: "",
                tone: .friendly
            )
            upsells = try await aiService.suggestUpsells(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
