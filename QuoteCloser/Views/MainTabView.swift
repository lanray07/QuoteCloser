import SwiftData
import SwiftUI

struct MainTabView: View {
    let profile: BusinessProfile

    @State private var dashboardRouter = AppRouter()
    @State private var pipelineRouter = AppRouter()
    @State private var toolsRouter = AppRouter()
    @State private var analyticsRouter = AppRouter()
    @State private var settingsRouter = AppRouter()

    var body: some View {
        TabView {
            tabStack(router: dashboardRouter) {
                DashboardView(profile: profile)
            }
            .tabItem { Label("Dashboard", systemImage: "gauge.with.dots.needle.bottom.50percent") }

            tabStack(router: pipelineRouter) {
                QuotePipelineView()
            }
            .tabItem { Label("Pipeline", systemImage: "list.bullet.rectangle") }

            tabStack(router: toolsRouter) {
                AIWorkbenchView()
            }
            .tabItem { Label("AI Tools", systemImage: "sparkles") }

            tabStack(router: analyticsRouter) {
                AnalyticsView()
            }
            .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }

            tabStack(router: settingsRouter) {
                SettingsView(profile: profile)
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }

    private func tabStack<Content: View>(
        router: AppRouter,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        NavigationStack(path: Binding(get: { router.path }, set: { router.path = $0 })) {
            content()
                .navigationDestination(for: AppRoute.self) { route in
                    AppRouteDestination(route: route)
                }
        }
        .environment(router)
    }
}

private struct AppRouteDestination: View {
    let route: AppRoute

    @Query(sort: \Client.createdAt, order: .reverse) private var clients: [Client]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    var body: some View {
        switch route {
        case .clientDetails(let clientID):
            ClientDetailView(client: client(for: clientID))
        case .quoteBuilder(let clientID):
            QuoteBuilderView(client: client(for: clientID))
        case .quoteDetail(let quoteID):
            if let quote = quote(for: quoteID) {
                QuoteDetailView(quote: quote)
            } else {
                missingView
            }
        case .proposalGenerator(let quoteID):
            ProposalGeneratorView(quote: quote(for: quoteID))
        case .objectionHandler(let quoteID):
            ObjectionHandlerView(quote: quote(for: quoteID))
        case .followUpWriter(let quoteID):
            FollowUpWriterView(quote: quote(for: quoteID))
        case .upsellEngine:
            UpsellEngineView()
        case .voiceToQuote:
            VoiceToQuoteView()
        case .savedTemplates:
            SavedTemplatesView()
        case .paywall:
            PaywallView()
        }
    }

    private var missingView: some View {
        EmptyStateView(
            title: "Item not found",
            message: "This local record may have been deleted.",
            systemImage: "questionmark.folder"
        )
        .padding()
        .navigationTitle("Not Found")
    }

    private func client(for id: UUID?) -> Client? {
        guard let id else { return nil }
        return clients.first { $0.id == id }
    }

    private func quote(for id: UUID?) -> Quote? {
        guard let id else { return nil }
        return quotes.first { $0.id == id }
    }
}
