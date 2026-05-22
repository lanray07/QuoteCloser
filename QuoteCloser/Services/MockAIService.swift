import Foundation

struct MockAIService: AIService {
    func generateProposal(_ request: AIRequestContext) async throws -> ProposalDraft {
        try await shortDelay()

        return ProposalDraft(
            title: "\(request.cleanServiceType.capitalized) Proposal",
            summary: "Thank you for the opportunity to quote for \(request.cleanServiceType). This proposal sets out a clear scope, transparent pricing, sensible exclusions, and next steps so the client can make a confident decision.",
            scopeOfWork: "We will complete the agreed \(request.cleanServiceType) using appropriate materials, safe working practices, tidy site management, and clear communication from start to finish.",
            includedServices: [
                "Pre-start review of the work area and requirements",
                "Labour, materials, travel, and equipment included in the quoted price",
                "Professional delivery of the agreed service",
                "Clean-down and handover notes once the work is complete"
            ],
            exclusions: [
                "Hidden defects or additional works discovered after approval",
                "Planning, permits, specialist reports, or third-party fees unless stated",
                "Changes requested after acceptance"
            ],
            timeline: "We can confirm the final start date after acceptance. Standard works are scheduled in the next available slot, with urgent work prioritised where possible.",
            optionalUpgrades: (try await suggestUpsells(request)).map { "\($0.title) - \(AppFormatters.currencyString($0.estimatedValue))" },
            paymentTerms: "A deposit may be required to secure materials and scheduling. The remaining balance is due on completion unless otherwise agreed in writing.",
            clientFriendlyExplanation: "This quote is built to avoid surprises: it separates the agreed work, what is included, what is not included, and optional upgrades that may improve the outcome.",
            acceptanceCTA: "To accept, reply with approval or sign the acceptance section. AI-generated proposal text should be reviewed before sending."
        )
    }

    func suggestUpsells(_ request: AIRequestContext) async throws -> [UpsellDraft] {
        try await shortDelay()

        switch request.businessType {
        case .roofer:
            return [
                UpsellDraft(title: "Gutter Cleaning", description: "Clear gutters while the roof team is already on site.", estimatedValue: 180),
                UpsellDraft(title: "Roof Health Inspection", description: "Document condition, small defects, and recommended maintenance.", estimatedValue: 240),
                UpsellDraft(title: "Moss Removal Treatment", description: "Remove moss build-up and apply preventative treatment.", estimatedValue: 350)
            ]
        case .landscaper:
            return [
                UpsellDraft(title: "Drainage Improvement", description: "Add drainage support to protect the finish in wet weather.", estimatedValue: 550),
                UpsellDraft(title: "Garden Lighting", description: "Install low-voltage lighting for safer and more premium outdoor use.", estimatedValue: 750),
                UpsellDraft(title: "Maintenance Plan", description: "Monthly care plan to keep the finished space looking sharp.", estimatedValue: 120)
            ]
        case .cleaner:
            return [
                UpsellDraft(title: "Deep Clean Add-on", description: "A detailed deep clean before or after the standard service.", estimatedValue: 160),
                UpsellDraft(title: "Recurring Plan", description: "Turn the one-off clean into a recurring weekly or monthly schedule.", estimatedValue: 95),
                UpsellDraft(title: "Carpet Clean", description: "Add carpet and rug cleaning to lift the final result.", estimatedValue: 140)
            ]
        case .plumber:
            return [
                UpsellDraft(title: "Maintenance Check", description: "Inspect nearby plumbing while already attending the job.", estimatedValue: 120),
                UpsellDraft(title: "Leak Inspection", description: "Check visible joins, seals, and pressure concerns.", estimatedValue: 95),
                UpsellDraft(title: "Priority Callout Cover", description: "Offer priority support for future urgent issues.", estimatedValue: 180)
            ]
        case .agency:
            return [
                UpsellDraft(title: "SEO Setup", description: "Improve discoverability alongside the core project.", estimatedValue: 600),
                UpsellDraft(title: "Analytics Dashboard", description: "Track conversion, traffic, and campaign performance.", estimatedValue: 450),
                UpsellDraft(title: "Monthly Support", description: "Ongoing support, updates, and optimisation.", estimatedValue: 500)
            ]
        case .electrician:
            return [
                UpsellDraft(title: "Safety Certificate", description: "Add a compliance check and certificate where appropriate.", estimatedValue: 180),
                UpsellDraft(title: "Smart Controls", description: "Offer timer, sensor, or smart-home control upgrades.", estimatedValue: 260),
                UpsellDraft(title: "Outdoor Lighting", description: "Add exterior lighting for safety and kerb appeal.", estimatedValue: 420)
            ]
        case .decorator:
            return [
                UpsellDraft(title: "Premium Paint Upgrade", description: "Offer washable or higher-durability finishes.", estimatedValue: 220),
                UpsellDraft(title: "Feature Wall", description: "Add a high-impact accent wall or papered finish.", estimatedValue: 300),
                UpsellDraft(title: "Touch-up Pack", description: "Provide labelled leftover paint and touch-up care notes.", estimatedValue: 65)
            ]
        case .drivewayInstaller:
            return [
                UpsellDraft(title: "Sealant Upgrade", description: "Protect the surface and improve long-term finish.", estimatedValue: 350),
                UpsellDraft(title: "Drainage Channel", description: "Improve water management at the driveway edge.", estimatedValue: 480),
                UpsellDraft(title: "Kerb Edging", description: "Add a cleaner boundary and more premium appearance.", estimatedValue: 420)
            ]
        case .freelancer, .localServiceBusiness:
            return [
                UpsellDraft(title: "Priority Turnaround", description: "Offer a faster delivery window where capacity allows.", estimatedValue: 150),
                UpsellDraft(title: "Monthly Support", description: "Convert the project into ongoing service and support.", estimatedValue: 300),
                UpsellDraft(title: "Premium Finish", description: "Add a higher-quality package with extra detail and assurance.", estimatedValue: 250)
            ]
        }
    }

    func handleObjection(_ objection: ObjectionType, request: AIRequestContext) async throws -> String {
        try await shortDelay()
        let tone = request.tone?.displayName.lowercased() ?? "friendly"

        switch objection {
        case .tooExpensive:
            return "Thanks for being open about budget. I understand price matters. This quote reflects the labour, materials, preparation, and finish needed to do the job properly. If helpful, I can also separate the must-have work from optional upgrades so you can choose the best fit."
        case .needToThink:
            return "Of course, take a little time to review it. I have kept the quote clear so you can compare scope, inclusions, and next steps. If any part is unclear, send me a quick message and I will talk you through it."
        case .competitorCheaper:
            return "I completely understand comparing options. The important thing is making sure the quotes cover the same scope, materials, preparation, and aftercare. If you want, I can highlight exactly what is included here so you can compare like for like."
        case .sooner:
            return "I can check the schedule and see what is realistic. I do not want to promise a date that risks quality, but if there is a safe way to bring it forward, I will let you know."
        case .discount:
            return "I have priced this to cover the right materials, time, and finish. Rather than cutting quality, I can look at adjusting optional items or phasing the work if that helps the budget."
        case .moreDetails:
            return "Absolutely. I will send a clearer breakdown of the scope, inclusions, exclusions, timings, and payment terms so you can make a confident decision. I have kept the tone \(tone) and easy to understand."
        }
    }

    func generateFollowUp(_ kind: FollowUpKind, request: AIRequestContext) async throws -> String {
        try await shortDelay()
        let service = request.cleanServiceType

        switch kind {
        case .sms:
            return "Hi \(request.clientName.isEmpty ? "there" : request.clientName), just checking you received the quote for \(service). Happy to answer any questions or adjust optional extras if helpful."
        case .email:
            return "Hi \(request.clientName.isEmpty ? "there" : request.clientName),\n\nI wanted to follow up on the quote for \(service). The proposal includes the agreed scope, price breakdown, exclusions, optional upgrades, and acceptance steps. If you have any questions, I would be happy to help.\n\nKind regards"
        case .whatsApp:
            return "Hi \(request.clientName.isEmpty ? "there" : request.clientName), quick follow-up on the \(service) quote. Let me know if you want me to talk through the options or reserve a slot."
        case .reminder:
            return "Just a quick reminder that the quote for \(service) is ready to review. If the timing still works, I can confirm the next available slot."
        case .finalCheckIn:
            return "Hi \(request.clientName.isEmpty ? "there" : request.clientName), I am doing a final check-in on the \(service) quote before I close the follow-up. If you would like to go ahead or make changes, just let me know."
        case .reviewRequest:
            return "Thanks again for choosing us for \(service). If you are happy with the work, a short review would mean a lot and helps other customers choose with confidence."
        }
    }

    func summarizeVoiceNotes(_ transcript: String, request: AIRequestContext) async throws -> String {
        try await shortDelay()
        let cleanedTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTranscript.isEmpty else {
            return "No voice notes captured yet. Record the client request, site details, budget, urgency, and any exclusions."
        }

        return """
        Service requested: \(request.cleanServiceType)
        Client notes summary: \(cleanedTranscript)
        Suggested quote notes: Confirm access, measurements, materials, timeline, exclusions, and whether optional upgrades should be included.
        Follow-up angle: Send a clear proposal quickly and invite the client to choose optional extras before scheduling.
        """
    }

    private func shortDelay() async throws {
        try await Task.sleep(nanoseconds: 250_000_000)
    }
}
