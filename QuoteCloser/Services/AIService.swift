import Foundation

let quoteCloserInternalPrompt = """
You are QuoteCloser, an AI sales assistant for service businesses. Help users create professional quotes, proposals, upsells, objection responses, and follow-up messages. Use clear, persuasive, ethical sales language. Do not guarantee conversions, profit, legal outcomes, or financial results.
"""

struct AIRequestContext: Codable, Hashable {
    var businessType: BusinessType
    var serviceType: String
    var clientName: String
    var clientNotes: String
    var quoteDetails: String
    var tone: ToneOption?

    var cleanServiceType: String {
        serviceType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "the requested service" : serviceType
    }
}

struct ProposalDraft: Codable, Hashable {
    var title: String
    var summary: String
    var scopeOfWork: String
    var includedServices: [String]
    var exclusions: [String]
    var timeline: String
    var optionalUpgrades: [String]
    var paymentTerms: String
    var clientFriendlyExplanation: String
    var acceptanceCTA: String

    var fullContent: String {
        """
        Quote Summary
        \(summary)

        Scope of Work
        \(scopeOfWork)

        Included Services
        \(includedServices.map { "- \($0)" }.joined(separator: "\n"))

        Exclusions
        \(exclusions.map { "- \($0)" }.joined(separator: "\n"))

        Timeline
        \(timeline)

        Optional Upgrades
        \(optionalUpgrades.map { "- \($0)" }.joined(separator: "\n"))

        Payment Terms
        \(paymentTerms)

        Client-Friendly Explanation
        \(clientFriendlyExplanation)

        Acceptance
        \(acceptanceCTA)
        """
    }
}

struct UpsellDraft: Codable, Hashable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var estimatedValue: Double

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case estimatedValue
    }
}

protocol AIService {
    func generateProposal(_ request: AIRequestContext) async throws -> ProposalDraft
    func suggestUpsells(_ request: AIRequestContext) async throws -> [UpsellDraft]
    func handleObjection(_ objection: ObjectionType, request: AIRequestContext) async throws -> String
    func generateFollowUp(_ kind: FollowUpKind, request: AIRequestContext) async throws -> String
    func summarizeVoiceNotes(_ transcript: String, request: AIRequestContext) async throws -> String
}

struct AIBackendRequest: Codable {
    var module: String
    var businessType: String
    var serviceType: String
    var clientNotes: String
    var quoteDetails: String
    var tone: String
}

struct AIBackendResponse: Codable {
    var proposal: String?
    var upsells: [UpsellDraft]?
    var followUp: String?
    var objectionReply: String?
    var summary: String?
}
