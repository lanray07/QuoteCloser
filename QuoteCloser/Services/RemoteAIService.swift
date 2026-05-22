import Foundation

struct RemoteAIService: AIService {
    var endpoint = URL(string: "https://YOUR_BACKEND_URL.com/quotecloser-ai")!
    var urlSession: URLSession = .shared

    func generateProposal(_ request: AIRequestContext) async throws -> ProposalDraft {
        let response = try await perform(module: "proposal", request: request)
        let content = response.proposal ?? "The backend did not return proposal content."
        return ProposalDraft(
            title: "\(request.cleanServiceType.capitalized) Proposal",
            summary: content,
            scopeOfWork: content,
            includedServices: [],
            exclusions: [],
            timeline: "",
            optionalUpgrades: response.upsells?.map(\.title) ?? [],
            paymentTerms: "",
            clientFriendlyExplanation: "",
            acceptanceCTA: "Review, approve, and sign to accept."
        )
    }

    func suggestUpsells(_ request: AIRequestContext) async throws -> [UpsellDraft] {
        let response = try await perform(module: "upsells", request: request)
        return response.upsells ?? []
    }

    func handleObjection(_ objection: ObjectionType, request: AIRequestContext) async throws -> String {
        var request = request
        request.clientNotes += "\nObjection: \(objection.prompt)"
        let response = try await perform(module: "objection", request: request)
        return response.objectionReply ?? "The backend did not return an objection reply."
    }

    func generateFollowUp(_ kind: FollowUpKind, request: AIRequestContext) async throws -> String {
        var request = request
        request.clientNotes += "\nFollow-up type: \(kind.displayName)"
        let response = try await perform(module: "follow_up", request: request)
        return response.followUp ?? "The backend did not return a follow-up message."
    }

    func summarizeVoiceNotes(_ transcript: String, request: AIRequestContext) async throws -> String {
        var request = request
        request.clientNotes += "\nVoice transcript: \(transcript)"
        let response = try await perform(module: "voice_summary", request: request)
        return response.summary ?? "The backend did not return a voice-note summary."
    }

    private func perform(module: String, request: AIRequestContext) async throws -> AIBackendResponse {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(
            AIBackendRequest(
                module: module,
                businessType: request.businessType.displayName,
                serviceType: request.serviceType,
                clientNotes: request.clientNotes,
                quoteDetails: request.quoteDetails,
                tone: request.tone?.rawValue ?? ""
            )
        )

        let (data, response) = try await urlSession.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(AIBackendResponse.self, from: data)
    }
}
