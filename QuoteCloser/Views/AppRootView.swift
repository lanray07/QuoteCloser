import SwiftData
import SwiftUI

struct AppRootView: View {
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]

    var body: some View {
        Group {
            if let profile = profiles.first, profile.isOnboardingComplete {
                MainTabView(profile: profile)
            } else {
                OnboardingView()
            }
        }
        .environment(\.aiService, activeAIService)
        .task {
            await subscriptionStore.loadProducts()
        }
    }

    private var activeAIService: any AIService {
        if profiles.first?.mockAIEnabled == false {
            return RemoteAIService()
        }
        return MockAIService()
    }
}
