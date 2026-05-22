import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class QuoteBuilderViewModel {
    var serviceType: String
    var laborCostText: String
    var materialsCostText: String
    var travelCostText: String
    var equipmentCostText: String
    var discountText: String
    var profitMarginText: String
    var taxRateText: String
    var optionalExtras: String
    var suggestedUpsells: [UpsellDraft] = []
    var selectedUpsellIDs: Set<UUID> = []
    var isLoadingUpsells = false
    var errorMessage: String?

    init(
        serviceType: String = "",
        laborCostText: String = "",
        materialsCostText: String = "",
        travelCostText: String = "",
        equipmentCostText: String = "",
        discountText: String = "",
        profitMarginText: String = "30",
        taxRateText: String = "0",
        optionalExtras: String = ""
    ) {
        self.serviceType = serviceType
        self.laborCostText = laborCostText
        self.materialsCostText = materialsCostText
        self.travelCostText = travelCostText
        self.equipmentCostText = equipmentCostText
        self.discountText = discountText
        self.profitMarginText = profitMarginText
        self.taxRateText = taxRateText
        self.optionalExtras = optionalExtras
    }

    var calculation: QuoteCalculation {
        QuoteCalculator.calculate(
            laborCost: amount(laborCostText),
            materialsCost: amount(materialsCostText),
            travelCost: amount(travelCostText),
            equipmentCost: amount(equipmentCostText),
            discount: amount(discountText),
            profitMargin: amount(profitMarginText),
            taxRate: amount(taxRateText)
        )
    }

    var canSave: Bool {
        !serviceType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func loadUpsells(
        aiService: any AIService,
        profile: BusinessProfile?,
        client: Client?
    ) async {
        isLoadingUpsells = true
        errorMessage = nil
        defer { isLoadingUpsells = false }

        do {
            let request = AIRequestContext.make(
                quote: nil,
                client: client,
                profile: profile,
                extraNotes: "Service type: \(serviceType)"
            )
            suggestedUpsells = try await aiService.suggestUpsells(request)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createQuote(
        client: Client?,
        photoData: [Data],
        modelContext: ModelContext
    ) throws -> Quote {
        let quote = Quote(
            client: client,
            serviceType: serviceType,
            laborCost: amount(laborCostText),
            materialsCost: amount(materialsCostText),
            travelCost: amount(travelCostText),
            equipmentCost: amount(equipmentCostText),
            discount: amount(discountText),
            profitMargin: amount(profitMarginText),
            taxRate: amount(taxRateText),
            optionalExtras: optionalExtras
        )

        modelContext.insert(quote)

        for data in photoData {
            let photo = QuotePhoto(quote: quote, imageData: data)
            modelContext.insert(photo)
            quote.photos.append(photo)
        }

        for upsell in suggestedUpsells {
            let suggestion = UpsellSuggestion(
                quote: quote,
                title: upsell.title,
                description: upsell.description,
                estimatedValue: upsell.estimatedValue,
                selected: selectedUpsellIDs.contains(upsell.id)
            )
            modelContext.insert(suggestion)
            quote.upsells.append(suggestion)
        }

        client?.quotes.append(quote)
        try modelContext.save()
        return quote
    }

    private func amount(_ text: String) -> Double {
        let clean = text
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(clean) ?? 0
    }
}
