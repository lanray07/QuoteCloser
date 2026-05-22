import SwiftData
import SwiftUI

struct SettingsView: View {
    let profile: BusinessProfile

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionStore.self) private var subscriptionStore

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
                        profile.mockAIEnabled = $0
                        save()
                    }
                ))
                Text("Remote AI uses POST https://YOUR_BACKEND_URL.com/quotecloser-ai and should call your secure backend. Never store API keys inside the app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
