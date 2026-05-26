import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct QuoteBuilderView: View {
    let client: Client?

    @Environment(\.aiService) private var aiService
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]

    @State private var viewModel: QuoteBuilderViewModel
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var photoData: [Data] = []
    @State private var saveError: String?
    @State private var activeSheet: QuoteBuilderSheet?
    @State private var pendingAIAction: (() -> Void)?
    @State private var showsAIConsent = false

    init(client: Client? = nil) {
        self.client = client
        _viewModel = State(initialValue: QuoteBuilderViewModel(serviceType: client?.serviceRequested ?? ""))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if let client {
                    ClientCard(client: client)
                }

                if let saveError {
                    ErrorBanner(message: saveError)
                }

                pricingInputs(viewModel: $viewModel)
                totalsCard
                photosSection
                AIDataSharingNotice(profile: profiles.first)
                upsellSection(viewModel: $viewModel)
                DisclaimerNotice()

                Button {
                    saveQuote()
                } label: {
                    Label("Save Quote", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.canSave)
            }
            .padding()
        }
        .navigationTitle("Quote Builder")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    requestAIConsentIfNeeded {
                        Task {
                            await viewModel.loadUpsells(
                                aiService: aiService,
                                profile: profiles.first,
                                client: client
                            )
                        }
                    }
                } label: {
                    Image(systemName: "sparkles")
                }
                .accessibilityLabel("Suggest upsells")
            }
        }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task {
                await loadSelectedPhotos(newItems)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .camera:
                CameraPicker { data in
                    photoData.append(data)
                }
            }
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
    }

    private func pricingInputs(viewModel: Bindable<QuoteBuilderViewModel>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quote Inputs")
                .font(.headline)

            TextField("Service type", text: viewModel.serviceType)
                .textFieldStyle(.roundedBorder)

            MoneyTextField(title: "Labour cost", text: viewModel.laborCostText)
            MoneyTextField(title: "Materials cost", text: viewModel.materialsCostText)
            MoneyTextField(title: "Travel cost", text: viewModel.travelCostText)
            MoneyTextField(title: "Equipment cost", text: viewModel.equipmentCostText)
            MoneyTextField(title: "Discount", text: viewModel.discountText)
            MoneyTextField(title: "Profit margin %", text: viewModel.profitMarginText)
            MoneyTextField(title: "VAT/tax placeholder %", text: viewModel.taxRateText)

            TextField("Optional extras notes", text: viewModel.optionalExtras, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...5)
        }
        .quoteCloserCard()
    }

    private var totalsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quote Output")
                .font(.headline)
            CalculationRow(title: "Subtotal", value: viewModel.calculation.subtotal)
            CalculationRow(title: "Tax", value: viewModel.calculation.taxAmount)
            CalculationRow(title: "Total price", value: viewModel.calculation.totalPrice, emphasized: true)
            CalculationRow(title: "Profit estimate", value: viewModel.calculation.profitEstimate)
            HStack {
                Text("Margin percentage")
                Spacer()
                Text("\(viewModel.calculation.marginPercentage.formatted(.number.precision(.fractionLength(0...1))))%")
                    .fontWeight(.semibold)
            }
        }
        .quoteCloserCard()
    }

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Uploaded Photos")
                    .font(.headline)
                Spacer()
                PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 8, matching: .images) {
                    Label("Add", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        activeSheet = .camera
                    } label: {
                        Image(systemName: "camera")
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Take photo")
                }
            }

            if photoData.isEmpty {
                Text("Attach job-site photos for proposal context and records.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(photoData.enumerated()), id: \.offset) { _, data in
                            if let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 82, height: 82)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .quoteCloserCard()
    }

    private func upsellSection(viewModel: Bindable<QuoteBuilderViewModel>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recommended Upsells")
                    .font(.headline)
                Spacer()
                if viewModel.isLoadingUpsells.wrappedValue {
                    ProgressView()
                }
            }

            if let error = viewModel.errorMessage.wrappedValue {
                ErrorBanner(message: error)
            }

            if viewModel.suggestedUpsells.wrappedValue.isEmpty {
                Button {
                    requestAIConsentIfNeeded {
                        Task {
                            await self.viewModel.loadUpsells(
                                aiService: aiService,
                                profile: profiles.first,
                                client: client
                            )
                        }
                    }
                } label: {
                    Label("Suggest Upsells", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                ForEach(viewModel.suggestedUpsells.wrappedValue) { upsell in
                    UpsellCard(
                        title: upsell.title,
                        description: upsell.description,
                        estimatedValue: upsell.estimatedValue,
                        isSelected: viewModel.selectedUpsellIDs.wrappedValue.contains(upsell.id)
                    ) {
                        var ids = viewModel.selectedUpsellIDs.wrappedValue
                        if ids.contains(upsell.id) {
                            ids.remove(upsell.id)
                        } else {
                            ids.insert(upsell.id)
                        }
                        viewModel.selectedUpsellIDs.wrappedValue = ids
                    }
                }
            }
        }
    }

    private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
        var loaded: [Data] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                loaded.append(data)
            }
        }
        photoData = loaded
    }

    private func saveQuote() {
        do {
            let quote = try viewModel.createQuote(
                client: client,
                photoData: photoData,
                modelContext: modelContext
            )
            saveError = nil
            router.navigate(to: .quoteDetail(quote.id))
        } catch {
            saveError = error.localizedDescription
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

private enum QuoteBuilderSheet: Identifiable {
    case camera

    var id: String { "camera" }
}

private struct MoneyTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 145, alignment: .leading)
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private struct CalculationRow: View {
    let title: String
    let value: Double
    var emphasized = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(AppFormatters.currencyString(value))
                .fontWeight(emphasized ? .bold : .semibold)
        }
        .font(emphasized ? .headline : .subheadline)
    }
}
