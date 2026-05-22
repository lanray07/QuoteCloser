import SwiftData
import SwiftUI

struct QuotePipelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.pdfProposalRenderer) private var pdfRenderer
    @Environment(AppRouter.self) private var router
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    @State private var filterRaw = "all"
    @State private var sharePayload: SharePayload?
    @State private var errorMessage: String?

    private var filteredQuotes: [Quote] {
        guard filterRaw != "all", let status = QuoteStatus(rawValue: filterRaw) else {
            return quotes
        }
        return quotes.filter { $0.status == status }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14) {
                filterPicker

                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                if filteredQuotes.isEmpty {
                    EmptyStateView(
                        title: "No quotes in this view",
                        message: "Create a quote or change the status filter to see more pipeline items.",
                        systemImage: "list.bullet.rectangle",
                        actionTitle: "New Quote"
                    ) {
                        router.navigate(to: .clientDetails(nil))
                    }
                } else {
                    ForEach(filteredQuotes) { quote in
                        pipelineCard(for: quote)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Pipeline")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .clientDetails(nil))
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New quote")
            }
        }
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
    }

    private var filterPicker: some View {
        Picker("Status", selection: $filterRaw) {
            Text("All").tag("all")
            ForEach(QuoteStatus.allCases) { status in
                Text(status.displayName).tag(status.rawValue)
            }
        }
        .pickerStyle(.menu)
        .quoteCloserCard()
    }

    private func pipelineCard(for quote: Quote) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                router.navigate(to: .quoteDetail(quote.id))
            } label: {
                QuoteCard(quote: quote)
            }
            .buttonStyle(.plain)

            HStack {
                Menu {
                    ForEach(QuoteStatus.allCases) { status in
                        Button(status.displayName) {
                            quote.status = status
                            try? modelContext.save()
                        }
                    }
                } label: {
                    Label("Update Status", systemImage: "slider.horizontal.3")
                }
                .buttonStyle(.bordered)

                Button {
                    duplicate(quote)
                } label: {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .buttonStyle(.bordered)

                Button {
                    export(quote)
                } label: {
                    Label("PDF", systemImage: "doc.richtext")
                }
                .buttonStyle(.bordered)
            }

            DatePicker(
                "Follow-up date",
                selection: Binding(
                    get: { quote.followUpDate ?? Date().addingTimeInterval(86_400) },
                    set: {
                        quote.followUpDate = $0
                        quote.status = .followUpDue
                        try? modelContext.save()
                    }
                ),
                displayedComponents: .date
            )
        }
    }

    private func duplicate(_ quote: Quote) {
        let copy = Quote(
            client: quote.client,
            serviceType: quote.serviceType,
            laborCost: quote.laborCost,
            materialsCost: quote.materialsCost,
            travelCost: quote.travelCost,
            equipmentCost: quote.equipmentCost,
            discount: quote.discount,
            profitMargin: quote.profitMargin,
            taxRate: quote.taxRate,
            optionalExtras: quote.optionalExtras,
            status: .draft
        )
        modelContext.insert(copy)

        for upsell in quote.upsells {
            let copiedUpsell = UpsellSuggestion(
                quote: copy,
                title: upsell.title,
                description: upsell.details,
                estimatedValue: upsell.estimatedValue,
                selected: upsell.selected
            )
            modelContext.insert(copiedUpsell)
            copy.upsells.append(copiedUpsell)
        }

        try? modelContext.save()
        router.navigate(to: .quoteDetail(copy.id))
    }

    private func export(_ quote: Quote) {
        do {
            let proposal: Proposal
            if let latest = quote.proposals.sorted(by: { $0.createdAt > $1.createdAt }).first {
                proposal = latest
            } else {
                proposal = Proposal(
                    quote: quote,
                    title: "Quote Proposal",
                    content: "Quote Summary\n\(quote.quoteDetailsText())"
                )
                modelContext.insert(proposal)
                quote.proposals.append(proposal)
            }

            let url = try pdfRenderer.render(
                proposal: proposal,
                quote: quote,
                businessProfile: profiles.first,
                client: quote.client
            )
            proposal.pdfLocalURL = url
            try modelContext.save()
            errorMessage = nil
            sharePayload = SharePayload(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
