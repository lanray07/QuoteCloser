import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ProposalGeneratorViewModel {
    var generatedProposal: Proposal?
    var isLoading = false
    var errorMessage: String?

    func generate(
        for quote: Quote,
        profile: BusinessProfile?,
        aiService: any AIService,
        modelContext: ModelContext
    ) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = AIRequestContext.make(
                quote: quote,
                client: quote.client,
                profile: profile
            )
            let draft = try await aiService.generateProposal(request)
            let proposal = Proposal(
                quote: quote,
                title: draft.title,
                content: draft.fullContent
            )
            modelContext.insert(proposal)
            quote.proposals.append(proposal)
            try modelContext.save()
            generatedProposal = proposal
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
