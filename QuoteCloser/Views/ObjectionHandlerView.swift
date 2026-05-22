import SwiftData
import SwiftUI

struct ObjectionHandlerView: View {
    let quote: Quote?

    @Environment(\.aiService) private var aiService
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    @State private var viewModel = ObjectionHandlerViewModel()
    @State private var selectedQuoteID: UUID?

    private var activeQuote: Quote? {
        quote ?? quotes.first { $0.id == selectedQuoteID } ?? quotes.first
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                quoteSelection

                VStack(alignment: .leading, spacing: 12) {
                    Picker("Objection", selection: $viewModel.objection) {
                        ForEach(ObjectionType.allCases) { objection in
                            Text(objection.displayName).tag(objection)
                        }
                    }

                    Picker("Tone", selection: $viewModel.tone) {
                        ForEach(ToneOption.allCases) { tone in
                            Text(tone.displayName).tag(tone)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .quoteCloserCard()

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                LoadingButton(
                    title: "Generate Reply",
                    systemImage: "quote.bubble",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.generate(
                            quote: activeQuote,
                            client: activeQuote?.client,
                            profile: profiles.first,
                            aiService: aiService
                        )
                    }
                }

                if viewModel.reply.isEmpty {
                    EmptyStateView(
                        title: "No reply generated",
                        message: "Pick a common objection and tone to draft a professional response.",
                        systemImage: "quote.bubble"
                    )
                } else {
                    Text(viewModel.reply)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .quoteCloserCard()
                }

                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Objection Handler")
        .onAppear {
            selectedQuoteID = quote?.id ?? quotes.first?.id
        }
    }

    private var quoteSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quote Context")
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
}
