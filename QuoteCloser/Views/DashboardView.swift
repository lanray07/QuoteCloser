import SwiftData
import SwiftUI

struct DashboardView: View {
    let profile: BusinessProfile

    @Environment(AppRouter.self) private var router
    @Environment(SubscriptionStore.self) private var subscriptionStore
    @Query(sort: \Client.createdAt, order: .reverse) private var clients: [Client]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    var body: some View {
        let viewModel = DashboardViewModel(
            clients: clients,
            quotes: quotes,
            subscriptionPlan: subscriptionStore.currentPlan
        )

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                header(viewModel: viewModel)

                if subscriptionStore.currentPlan == .free {
                    UpgradeBanner {
                        router.navigate(to: .paywall)
                    }
                }

                statsGrid(viewModel: viewModel)
                quickActions
                recentQuotes(viewModel: viewModel)
                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }

    private func header(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(profile.businessName.nonEmptyValue ?? "\(profile.businessType.displayName) Workspace")
                .font(.title2.bold())
            Text("\(profile.mainGoal.displayName) - \(subscriptionStore.currentPlan.displayName)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statsGrid(viewModel: DashboardViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            DashboardMetricTile(title: "New requests", value: "\(viewModel.newQuoteRequests)", systemImage: "tray.and.arrow.down")
            DashboardMetricTile(title: "Quotes sent", value: "\(viewModel.quotesSent)", systemImage: "paperplane")
            DashboardMetricTile(title: "Accepted", value: "\(viewModel.acceptedQuotes)", systemImage: "checkmark.seal")
            DashboardMetricTile(title: "Rejected", value: "\(viewModel.rejectedQuotes)", systemImage: "xmark.seal")
            DashboardMetricTile(title: "Follow-ups", value: "\(viewModel.pendingFollowUps)", systemImage: "bell.badge")
            DashboardMetricTile(title: "Pipeline", value: AppFormatters.currencyString(viewModel.estimatedPipelineValue), systemImage: "chart.line.uptrend.xyaxis")
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 12)], spacing: 12) {
                QuickActionButton(title: "New Quote", systemImage: "plus.circle") {
                    router.navigate(to: .clientDetails(nil))
                }
                QuickActionButton(title: "Generate Proposal", systemImage: "doc.badge.plus") {
                    router.navigate(to: .proposalGenerator(quotes.first?.id))
                }
                QuickActionButton(title: "Objection Handler", systemImage: "quote.bubble") {
                    router.navigate(to: .objectionHandler(quotes.first?.id))
                }
                QuickActionButton(title: "Follow-Up Writer", systemImage: "paperplane.circle") {
                    router.navigate(to: .followUpWriter(quotes.first?.id))
                }
                QuickActionButton(title: "Voice-to-Quote", systemImage: "waveform") {
                    router.navigate(to: .voiceToQuote)
                }
                QuickActionButton(title: "Saved Templates", systemImage: "doc.text.magnifyingglass") {
                    router.navigate(to: .savedTemplates)
                }
            }
        }
    }

    private func recentQuotes(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Quotes")
                .font(.headline)

            if viewModel.recentQuotes.isEmpty {
                EmptyStateView(
                    title: "No quotes yet",
                    message: "Create your first lead and quote to start building a pipeline.",
                    systemImage: "doc.badge.plus",
                    actionTitle: "New Quote"
                ) {
                    router.navigate(to: .clientDetails(nil))
                }
            } else {
                ForEach(viewModel.recentQuotes) { quote in
                    Button {
                        router.navigate(to: .quoteDetail(quote.id))
                    } label: {
                        QuoteCard(quote: quote)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct DashboardMetricTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
            Text(value)
                .font(.title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .quoteCloserCard()
    }
}

private struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .frame(width: 24)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
