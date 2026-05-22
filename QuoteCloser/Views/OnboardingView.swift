import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]

    @State private var businessType: BusinessType = .roofer
    @State private var mainGoal: MainGoal = .sendQuotesFaster
    @State private var businessName = ""
    @State private var ownerName = ""
    @State private var email = ""
    @State private var phone = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QuoteCloser")
                            .font(.largeTitle.bold())
                        Text("Build better quotes, proposals, follow-ups, and sales replies from one local-first workspace.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Business Type") {
                    Picker("Business Type", selection: $businessType) {
                        ForEach(BusinessType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }

                Section("Main Goal") {
                    Picker("Main Goal", selection: $mainGoal) {
                        ForEach(MainGoal.allCases) { goal in
                            Text(goal.displayName).tag(goal)
                        }
                    }
                }

                Section("Business Details") {
                    TextField("Business name", text: $businessName)
                        .textContentType(.organizationName)
                    TextField("Your name", text: $ownerName)
                        .textContentType(.name)
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }

                Section {
                    Button {
                        completeOnboarding()
                    } label: {
                        Label("Start Closing Quotes", systemImage: "arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Setup")
        }
    }

    private func completeOnboarding() {
        let profile = profiles.first ?? BusinessProfile()
        profile.businessType = businessType
        profile.mainGoal = mainGoal
        profile.businessName = businessName
        profile.ownerName = ownerName
        profile.email = email
        profile.phone = phone
        profile.mockAIEnabled = true
        profile.isOnboardingComplete = true
        profile.updatedAt = .now

        if profiles.isEmpty {
            modelContext.insert(profile)
        }

        try? modelContext.save()
    }
}
