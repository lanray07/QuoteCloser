import SwiftUI

struct UpsellEngineView: View {
    @Environment(\.aiService) private var aiService
    @State private var viewModel = UpsellEngineViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Upsell Engine")
                        .font(.headline)

                    Picker("Business type", selection: $viewModel.businessType) {
                        ForEach(BusinessType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    TextField("Service type", text: $viewModel.serviceType)
                        .textFieldStyle(.roundedBorder)

                    TextField("Client notes", text: $viewModel.clientNotes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                .quoteCloserCard()

                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                LoadingButton(
                    title: "Suggest Upsells",
                    systemImage: "sparkles",
                    isLoading: viewModel.isLoading
                ) {
                    Task { await viewModel.generate(aiService: aiService) }
                }

                if viewModel.upsells.isEmpty {
                    EmptyStateView(
                        title: "No upsells yet",
                        message: "Choose a trade and service, then generate relevant add-ons.",
                        systemImage: "arrow.up.right.circle"
                    )
                } else {
                    ForEach(viewModel.upsells) { upsell in
                        UpsellCard(
                            title: upsell.title,
                            description: upsell.description,
                            estimatedValue: upsell.estimatedValue,
                            isSelected: false,
                            onToggle: nil
                        )
                    }
                }

                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Upsells")
    }
}
