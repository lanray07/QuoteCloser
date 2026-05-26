import SwiftData
import SwiftUI

struct ProposalGeneratorView: View {
    let quote: Quote?

    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.pdfProposalRenderer) private var pdfRenderer
    @Environment(AppRouter.self) private var router
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    @State private var viewModel = ProposalGeneratorViewModel()
    @State private var selectedQuoteID: UUID?
    @State private var sharePayload: SharePayload?
    @State private var exportError: String?
    @State private var pendingAIAction: (() -> Void)?
    @State private var showsAIConsent = false

    private var activeQuote: Quote? {
        quote ?? quotes.first { $0.id == selectedQuoteID } ?? quotes.first
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                quoteSelection

                if let error = viewModel.errorMessage ?? exportError {
                    ErrorBanner(message: error)
                }

                if let activeQuote {
                    QuoteCard(quote: activeQuote)
                    AIDataSharingNotice(profile: profiles.first)

                    LoadingButton(
                        title: "Generate Proposal",
                        systemImage: "sparkles",
                        isLoading: viewModel.isLoading
                    ) {
                        requestAIConsentIfNeeded {
                            Task {
                                await viewModel.generate(
                                    for: activeQuote,
                                    profile: profiles.first,
                                    aiService: aiService,
                                    modelContext: modelContext
                                )
                            }
                        }
                    }

                    proposalsSection(for: activeQuote)
                    DisclaimerNotice()
                } else {
                    EmptyStateView(
                        title: "No quote available",
                        message: "Create a quote first, then generate a proposal from the pricing and client notes.",
                        systemImage: "doc.badge.plus",
                        actionTitle: "New Quote"
                    ) {
                        router.navigate(to: .clientDetails(nil))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Proposal")
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
        .sheet(isPresented: $showsAIConsent) {
            AIDataSharingConsentSheet {
                AIDataSharingPolicy.grantConsent(profile: profiles.first, modelContext: modelContext)
                showsAIConsent = false
                pendingAIAction?()
                pendingAIAction = nil
            } onKeepLocal: {
                showsAIConsent = false
                pendingAIAction = nil
            }
        }
        .onAppear {
            if selectedQuoteID == nil {
                selectedQuoteID = quote?.id ?? quotes.first?.id
            }
        }
    }

    private var quoteSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quote")
                .font(.headline)
            Picker("Quote", selection: $selectedQuoteID) {
                ForEach(quotes) { quote in
                    Text("\(quote.serviceType.nonEmptyValue ?? "Quote") - \(quote.client?.name.nonEmptyValue ?? "Client")")
                        .tag(Optional(quote.id))
                }
            }
            .pickerStyle(.menu)
        }
        .quoteCloserCard()
    }

    private func proposalsSection(for quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Generated Proposals")
                    .font(.headline)
                Spacer()
                Button {
                    exportLatestProposal(for: quote)
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }

            let proposals = quote.proposals.sorted { $0.createdAt > $1.createdAt }
            if proposals.isEmpty {
                Text("Generated proposal content will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .quoteCloserCard()
            } else {
                ForEach(proposals) { proposal in
                    VStack(alignment: .leading, spacing: 10) {
                        ProposalCard(proposal: proposal)
                        Button {
                            export(proposal: proposal, quote: quote)
                        } label: {
                            Label("Export PDF", systemImage: "doc.richtext")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    private func exportLatestProposal(for quote: Quote) {
        let proposal = quote.proposals.sorted { $0.createdAt > $1.createdAt }.first
        if let proposal {
            export(proposal: proposal, quote: quote)
        } else {
            let fallback = Proposal(
                quote: quote,
                title: "Quote Proposal",
                content: "Quote Summary\n\(quote.quoteDetailsText())"
            )
            modelContext.insert(fallback)
            quote.proposals.append(fallback)
            try? modelContext.save()
            export(proposal: fallback, quote: quote)
        }
    }

    private func export(proposal: Proposal, quote: Quote) {
        do {
            let url = try pdfRenderer.render(
                proposal: proposal,
                quote: quote,
                businessProfile: profiles.first,
                client: quote.client
            )
            proposal.pdfLocalURL = url
            try modelContext.save()
            exportError = nil
            sharePayload = SharePayload(url: url)
        } catch {
            exportError = error.localizedDescription
        }
    }

    private func requestAIConsentIfNeeded(_ action: @escaping () -> Void) {
        if AIDataSharingPolicy.requiresConsent(profile: profiles.first) {
            pendingAIAction = action
            showsAIConsent = true
        } else {
            action()
        }
    }
}
