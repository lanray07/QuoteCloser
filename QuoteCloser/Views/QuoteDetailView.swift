import SwiftData
import SwiftUI
import UIKit

struct QuoteDetailView: View {
    let quote: Quote

    @Environment(\.modelContext) private var modelContext
    @Environment(\.pdfProposalRenderer) private var pdfRenderer
    @Environment(AppRouter.self) private var router
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]

    @State private var sharePayload: SharePayload?
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if let errorMessage {
                    ErrorBanner(message: errorMessage)
                }

                QuoteCard(quote: quote)
                statusSection
                totalsSection
                clientSection
                upsellsSection
                proposalsSection
                followUpsSection
                photosSection
                actionsSection
                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Quote Detail")
        .sheet(item: $sharePayload) { payload in
            ShareSheet(items: [payload.url])
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status")
                .font(.headline)
            Picker("Status", selection: Binding(get: { quote.status }, set: updateStatus)) {
                ForEach(QuoteStatus.allCases) { status in
                    Text(status.displayName).tag(status)
                }
            }
            .pickerStyle(.menu)

            DatePicker(
                "Follow-up date",
                selection: Binding(
                    get: { quote.followUpDate ?? Date().addingTimeInterval(86_400) },
                    set: {
                        quote.followUpDate = $0
                        try? modelContext.save()
                    }
                ),
                displayedComponents: .date
            )

            if quote.status == .rejected {
                TextField("Lost quote reason", text: Binding(get: { quote.lostReason }, set: { quote.lostReason = $0 }))
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { try? modelContext.save() }
            }
        }
        .quoteCloserCard()
    }

    private var totalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Price Breakdown")
                .font(.headline)
            DetailRow(title: "Labour", value: AppFormatters.currencyString(quote.laborCost))
            DetailRow(title: "Materials", value: AppFormatters.currencyString(quote.materialsCost))
            DetailRow(title: "Travel", value: AppFormatters.currencyString(quote.travelCost))
            DetailRow(title: "Equipment", value: AppFormatters.currencyString(quote.equipmentCost))
            DetailRow(title: "Discount", value: AppFormatters.currencyString(quote.discount))
            DetailRow(title: "Total", value: AppFormatters.currencyString(quote.totalPrice), emphasized: true)
            DetailRow(title: "Profit", value: AppFormatters.currencyString(quote.profitEstimate))
        }
        .quoteCloserCard()
    }

    private var clientSection: some View {
        Group {
            if let client = quote.client {
                ClientCard(client: client)
            } else {
                EmptyStateView(
                    title: "No client attached",
                    message: "This quote can still be used, but client details make proposals stronger.",
                    systemImage: "person.crop.circle.badge.questionmark"
                )
            }
        }
    }

    private var upsellsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upsells")
                .font(.headline)

            if quote.upsells.isEmpty {
                EmptyStateView(
                    title: "No upsells saved",
                    message: "Generate upsells from the quote builder or AI tools.",
                    systemImage: "arrow.up.right.circle"
                )
            } else {
                ForEach(quote.upsells) { upsell in
                    UpsellCard(
                        title: upsell.title,
                        description: upsell.details,
                        estimatedValue: upsell.estimatedValue,
                        isSelected: upsell.selected
                    ) {
                        upsell.selected.toggle()
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    private var proposalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Proposals")
                    .font(.headline)
                Spacer()
                Button {
                    router.navigate(to: .proposalGenerator(quote.id))
                } label: {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("Generate proposal")
            }

            if quote.proposals.isEmpty {
                Text("No proposals generated yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .quoteCloserCard()
            } else {
                ForEach(quote.proposals.sorted { $0.createdAt > $1.createdAt }) { proposal in
                    ProposalCard(proposal: proposal)
                }
            }
        }
    }

    private var followUpsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Follow-Ups")
                    .font(.headline)
                Spacer()
                Button {
                    router.navigate(to: .followUpWriter(quote.id))
                } label: {
                    Image(systemName: "plus.circle")
                }
                .accessibilityLabel("Write follow-up")
            }

            if quote.followUps.isEmpty {
                Text("No follow-ups saved yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .quoteCloserCard()
            } else {
                ForEach(quote.followUps.sorted { $0.createdAt > $1.createdAt }) { followUp in
                    FollowUpCard(followUp: followUp)
                }
            }
        }
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photos")
                .font(.headline)

            if quote.photos.isEmpty {
                Text("No photos attached.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .quoteCloserCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(quote.photos) { photo in
                            if let data = photo.imageData, let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 110, height: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 10) {
            Button {
                router.navigate(to: .proposalGenerator(quote.id))
            } label: {
                Label("Generate Proposal", systemImage: "doc.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            HStack {
                Button {
                    router.navigate(to: .objectionHandler(quote.id))
                } label: {
                    Label("Objection", systemImage: "quote.bubble")
                }
                .buttonStyle(.bordered)

                Button {
                    router.navigate(to: .followUpWriter(quote.id))
                } label: {
                    Label("Follow-Up", systemImage: "paperplane")
                }
                .buttonStyle(.bordered)

                Button {
                    exportPDF()
                } label: {
                    Label("Export PDF", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func updateStatus(_ status: QuoteStatus) {
        quote.status = status
        if status == .followUpDue, quote.followUpDate == nil {
            quote.followUpDate = Date().addingTimeInterval(86_400)
        }
        try? modelContext.save()
    }

    private func exportPDF() {
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

private struct DetailRow: View {
    let title: String
    let value: String
    var emphasized = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(emphasized ? .bold : .semibold)
        }
        .font(emphasized ? .headline : .subheadline)
    }
}
