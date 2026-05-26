import SwiftData
import SwiftUI

struct SettingsView: View {
    let profile: BusinessProfile

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @State private var showsAIConsent = false

    var body: some View {
        Form {
            Section("Business") {
                TextField("Business name", text: binding(\.businessName))
                TextField("Owner name", text: binding(\.ownerName))
                TextField("Email", text: binding(\.email))
                    .keyboardType(.emailAddress)
                TextField("Phone", text: binding(\.phone))
                    .keyboardType(.phonePad)
                TextField("Address", text: binding(\.address), axis: .vertical)
                    .lineLimit(2...4)
                TextField("Website", text: binding(\.website))
                    .keyboardType(.URL)
            }

            Section("Positioning") {
                Picker("Business type", selection: businessTypeBinding) {
                    ForEach(BusinessType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }

                Picker("Main goal", selection: mainGoalBinding) {
                    ForEach(MainGoal.allCases) { goal in
                        Text(goal.displayName).tag(goal)
                    }
                }
            }

            Section("AI") {
                Toggle("Mock AI mode", isOn: Binding(
                    get: { profile.mockAIEnabled },
                    set: {
                        if $0 {
                            profile.mockAIEnabled = true
                            profile.remoteAIConsentGranted = false
                            save()
                        } else {
                            showsAIConsent = true
                        }
                    }
                ))
                Text(profile.mockAIEnabled ? "Mock AI is enabled. Quote, client, and voice-note data is not sent to an AI service." : "Remote AI uses POST https://YOUR_BACKEND_URL.com/quotecloser-ai through your secure backend. AI generation actions may send business type, service type, client notes, quote details, selected tone, and voice transcripts after consent. Never store API keys inside the app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !profile.mockAIEnabled {
                    Label(profile.remoteAIConsentGranted ? "Remote AI data sharing allowed" : "Remote AI requires permission before use", systemImage: profile.remoteAIConsentGranted ? "checkmark.shield" : "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(profile.remoteAIConsentGranted ? .green : .orange)
                }
            }

            Section("Subscription") {
                HStack {
                    Text("Current plan")
                    Spacer()
                    Text(subscriptionStore.currentPlan.displayName)
                        .foregroundStyle(.secondary)
                }
                Button {
                    router.navigate(to: .paywall)
                } label: {
                    Label("Manage Plan", systemImage: "creditcard")
                }
            }

            Section("Disclaimer") {
                Text("AI content should be reviewed. Pricing estimates are not guaranteed. QuoteCloser is not legal or financial advice. You are responsible for final contracts and pricing.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: save)
            }
        }
        .sheet(isPresented: $showsAIConsent) {
            AIDataSharingConsentSheet {
                profile.mockAIEnabled = false
                AIDataSharingPolicy.grantConsent(profile: profile, modelContext: modelContext)
                showsAIConsent = false
            } onKeepLocal: {
                profile.mockAIEnabled = true
                profile.remoteAIConsentGranted = false
                save()
                showsAIConsent = false
            }
        }
    }

    private func binding(_ keyPath: ReferenceWritableKeyPath<BusinessProfile, String>) -> Binding<String> {
        Binding(
            get: { profile[keyPath: keyPath] },
            set: {
                profile[keyPath: keyPath] = $0
                profile.updatedAt = .now
            }
        )
    }

    private var businessTypeBinding: Binding<BusinessType> {
        Binding(
            get: { profile.businessType },
            set: {
                profile.businessType = $0
                save()
            }
        )
    }

    private var mainGoalBinding: Binding<MainGoal> {
        Binding(
            get: { profile.mainGoal },
            set: {
                profile.mainGoal = $0
                save()
            }
        )
    }

    private func save() {
        profile.updatedAt = .now
        try? modelContext.save()
    }
}
