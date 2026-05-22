import Foundation
import Observation

@MainActor
@Observable
final class ObjectionHandlerViewModel {
    var objection: ObjectionType = .tooExpensive
    var tone: ToneOption = .friendly
    var reply: String = ""
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
            reply = try await aiService.handleObjection(objection, request: request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
