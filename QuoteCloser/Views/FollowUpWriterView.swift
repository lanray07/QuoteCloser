import SwiftData
import SwiftUI
import UIKit

struct FollowUpWriterView: View {
    let quote: Quote?

    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    @State private var viewModel = FollowUpWriterViewModel()
    @State private var selectedQuoteID: UUID?
    @State private var saveMessage: String?
    @State private var pendingAIAction: (() -> Void)?
    @State private var showsAIConsent = false

    private var activeQuote: Quote? {
        quote ?? quotes.first { $0.id == selectedQuoteID } ?? quotes.first
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                quoteSelection

                VStack(alignment: .leading, spacing: 12) {
                    Picker("Message type", selection: $viewModel.kind) {
                        ForEach(FollowUpKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
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

                AIDataSharingNotice(profile: profiles.first)

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                if let saveMessage {
                    Label(saveMessage, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .quoteCloserCard()
                }

                LoadingButton(
                    title: "Generate Follow-Up",
                    systemImage: "paperplane",
                    isLoading: viewModel.isLoading
                ) {
                    requestAIConsentIfNeeded {
                        Task {
                            await viewModel.generate(
                                quote: activeQuote,
                                client: activeQuote?.client,
                                profile: profiles.first,
                                aiService: aiService
                            )
                        }
                    }
                }

                if viewModel.content.isEmpty {
                    EmptyStateView(
                        title: "No follow-up written",
                        message: "Generate SMS, email, WhatsApp-style, reminder, final check-in, or review request copy.",
                        systemImage: "paperplane"
                    )
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.content)
                            .textSelection(.enabled)
                        HStack {
                            Button {
                                UIPasteboard.general.string = viewModel.content
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.bordered)

                            Button {
                                saveFollowUp()
                            } label: {
                                Label("Save", systemImage: "tray.and.arrow.down")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(activeQuote == nil)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .quoteCloserCard()
                }

                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Follow-Up Writer")
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

    private func saveFollowUp() {
        do {
            try viewModel.save(quote: activeQuote, modelContext: modelContext)
            saveMessage = "Follow-up saved to quote."
        } catch {
            viewModel.errorMessage = error.localizedDescription
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
