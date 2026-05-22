import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionStore.self) private var subscriptionStore

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("QuoteCloser Plans")
                        .font(.largeTitle.bold())
                    Text("Choose the level that matches how much quoting, follow-up, and proposal work you want to automate.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let error = subscriptionStore.errorMessage {
                    ErrorBanner(message: error)
                }

                PlanCard(
                    plan: .free,
                    product: nil,
                    isCurrent: subscriptionStore.currentPlan == .free,
                    features: [
                        "5 quotes/month",
                        "Basic proposal export",
                        "Limited follow-ups",
                        "QuoteCloser branding"
                    ],
                    isLoading: subscriptionStore.isLoading
                ) { _ in }

                PlanCard(
                    plan: .proMonthly,
                    product: subscriptionStore.product(for: .proMonthly),
                    isCurrent: subscriptionStore.currentPlan == .proMonthly,
                    features: [
                        "Unlimited quotes",
                        "AI proposal generator",
                        "AI objection handler",
                        "PDF exports",
                        "Quote pipeline",
                        "Analytics"
                    ],
                    isLoading: subscriptionStore.isLoading
                ) { product in
                    Task { await subscriptionStore.purchase(product) }
                }

                PlanCard(
                    plan: .proYearly,
                    product: subscriptionStore.product(for: .proYearly),
                    isCurrent: subscriptionStore.currentPlan == .proYearly,
                    features: [
                        "Everything in Pro",
                        "Lower annual placeholder price",
                        "Best fit for regular quoting"
                    ],
                    isLoading: subscriptionStore.isLoading
                ) { product in
                    Task { await subscriptionStore.purchase(product) }
                }

                PlanCard(
                    plan: .businessMonthly,
                    product: subscriptionStore.product(for: .businessMonthly),
                    isCurrent: subscriptionStore.currentPlan == .businessMonthly,
                    features: [
                        "Custom branding",
                        "Advanced analytics",
                        "Team workflow placeholder",
                        "Saved pricing templates",
                        "White-label proposals"
                    ],
                    isLoading: subscriptionStore.isLoading
                ) { product in
                    Task { await subscriptionStore.purchase(product) }
                }

                Button {
                    Task { await subscriptionStore.refreshEntitlements() }
                } label: {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Upgrade")
        .task {
            await subscriptionStore.loadProducts()
        }
    }
}

private struct PlanCard: View {
    let plan: SubscriptionPlan
    let product: Product?
    let isCurrent: Bool
    let features: [String]
    let isLoading: Bool
    let purchase: (Product) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.displayName)
                        .font(.title3.bold())
                    Text(product?.displayPrice ?? plan.placeholderPrice)
                        .font(.headline)
                        .foregroundStyle(Color.accentColor)
                }
                Spacer()
                if isCurrent {
                    Text("Current")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.green.opacity(0.12), in: Capsule())
                }
            }

            ForEach(features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark.circle")
                    .font(.subheadline)
            }

            if plan != .free {
                Button {
                    if let product {
                        purchase(product)
                    }
                } label: {
                    HStack {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "creditcard")
                        }
                        Text(product == nil ? "StoreKit product unavailable" : "Choose \(plan.displayName)")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(product == nil || isLoading || isCurrent)
            }
        }
        .quoteCloserCard()
    }
}
