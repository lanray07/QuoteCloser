import SwiftData
import SwiftUI

enum AIDataSharingPolicy {
    static let backendName = "QuoteCloser secure AI backend"
    static let backendURL = "https://YOUR_BACKEND_URL.com/quotecloser-ai"
    static let providerDescription = "QuoteCloser's secure AI backend and its AI generation provider"

    static func requiresConsent(profile: BusinessProfile?) -> Bool {
        guard let profile else { return false }
        return !profile.mockAIEnabled && !profile.remoteAIConsentGranted
    }

    static func grantConsent(profile: BusinessProfile?, modelContext: ModelContext) {
        guard let profile else { return }
        profile.remoteAIConsentGranted = true
        profile.updatedAt = .now
        try? modelContext.save()
    }
}

struct AIDataSharingNotice: View {
    let profile: BusinessProfile?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: profile?.mockAIEnabled == false ? "network" : "lock.shield")
                .font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .quoteCloserCard()
    }

    private var title: String {
        profile?.mockAIEnabled == false ? "Remote AI data sharing" : "Mock AI privacy"
    }

    private var message: String {
        if profile?.mockAIEnabled == false {
            "Remote AI may send business type, service type, client notes, quote details, selected tone, and voice transcripts to \(AIDataSharingPolicy.providerDescription) only when you choose an AI generation action."
        } else {
            "Mock AI is enabled. AI drafts are generated from built-in sample responses on this device, and client or quote data is not sent to an AI service."
        }
    }
}

struct AIDataSharingConsentSheet: View {
    let onAllow: () -> Void
    let onKeepLocal: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Label("Allow AI data sharing?", systemImage: "sparkles")
                        .font(.title3.bold())

                    Text("QuoteCloser needs your permission before sending quote or client information to a remote AI service.")
                        .foregroundStyle(.secondary)

                    disclosureSection(
                        title: "Data sent",
                        rows: [
                            "Business type and service type",
                            "Client name and client notes if included in the quote",
                            "Quote pricing details, scope notes, selected tone, and follow-up context",
                            "Voice transcripts only when you use Voice-to-Quote summarising"
                        ]
                    )

                    disclosureSection(
                        title: "Sent to",
                        rows: [
                            "\(AIDataSharingPolicy.backendName): \(AIDataSharingPolicy.backendURL)",
                            "The backend may use an AI generation provider to create proposals, upsells, objection replies, follow-ups, and voice-note summaries"
                        ]
                    )

                    disclosureSection(
                        title: "Used for",
                        rows: [
                            "Generating the AI response you request",
                            "Returning that response to this app",
                            "Not legal, financial, or guaranteed sales advice"
                        ]
                    )

                    VStack(spacing: 10) {
                        Button(action: onAllow) {
                            Label("Allow AI Data Sharing", systemImage: "checkmark.shield")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: onKeepLocal) {
                            Text("Keep Using Mock AI")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
            .navigationTitle("AI Privacy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func disclosureSection(title: String, rows: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            ForEach(rows, id: \.self) { row in
                Label(row, systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
