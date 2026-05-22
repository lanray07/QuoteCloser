import SwiftData
import SwiftUI

@main
struct QuoteCloserApp: App {
    @State private var subscriptionStore = SubscriptionStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(subscriptionStore)
        }
        .modelContainer(for: [
            BusinessProfile.self,
            Client.self,
            Quote.self,
            QuotePhoto.self,
            Proposal.self,
            FollowUpMessage.self,
            UpsellSuggestion.self,
            SubscriptionState.self
        ])
    }
}
