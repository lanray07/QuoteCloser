import Foundation
import SwiftData

@Model
final class Quote: Identifiable {
    @Attribute(.unique) var id: UUID
    var clientId: UUID?
    var serviceType: String
    var laborCost: Double
    var materialsCost: Double
    var travelCost: Double
    var equipmentCost: Double
    var discount: Double
    var profitMargin: Double
    var taxRate: Double
    var optionalExtras: String
    var totalPrice: Double
    var profitEstimate: Double
    var marginPercentage: Double
    var statusRaw: String
    var followUpDate: Date?
    var lostReason: String
    var createdAt: Date
    var updatedAt: Date

    var client: Client?

    @Relationship(deleteRule: .cascade, inverse: \QuotePhoto.quote)
    var photos: [QuotePhoto] = []

    @Relationship(deleteRule: .cascade, inverse: \Proposal.quote)
    var proposals: [Proposal] = []

    @Relationship(deleteRule: .cascade, inverse: \FollowUpMessage.quote)
    var followUps: [FollowUpMessage] = []

    @Relationship(deleteRule: .cascade, inverse: \UpsellSuggestion.quote)
    var upsells: [UpsellSuggestion] = []

    init(
        id: UUID = UUID(),
        client: Client? = nil,
        serviceType: String = "",
        laborCost: Double = 0,
        materialsCost: Double = 0,
        travelCost: Double = 0,
        equipmentCost: Double = 0,
        discount: Double = 0,
        profitMargin: Double = 30,
        taxRate: Double = 0,
        optionalExtras: String = "",
        status: QuoteStatus = .draft,
        followUpDate: Date? = nil,
        lostReason: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.client = client
        self.clientId = client?.id
        self.serviceType = serviceType
        self.laborCost = laborCost
        self.materialsCost = materialsCost
        self.travelCost = travelCost
        self.equipmentCost = equipmentCost
        self.discount = discount
        self.profitMargin = profitMargin
        self.taxRate = taxRate
        self.optionalExtras = optionalExtras
        self.statusRaw = status.rawValue
        self.followUpDate = followUpDate
        self.lostReason = lostReason
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        let calculation = QuoteCalculator.calculate(
            laborCost: laborCost,
            materialsCost: materialsCost,
            travelCost: travelCost,
            equipmentCost: equipmentCost,
            discount: discount,
            profitMargin: profitMargin,
            taxRate: taxRate
        )
        self.totalPrice = calculation.totalPrice
        self.profitEstimate = calculation.profitEstimate
        self.marginPercentage = calculation.marginPercentage
    }

    var status: QuoteStatus {
        get { QuoteStatus(rawValue: statusRaw) ?? .draft }
        set {
            statusRaw = newValue.rawValue
            updatedAt = .now
        }
    }

    var selectedUpsellValue: Double {
        upsells.filter(\.selected).reduce(0) { $0 + $1.estimatedValue }
    }

    var costSubtotal: Double {
        laborCost + materialsCost + travelCost + equipmentCost
    }

    func recalculateTotals() {
        let calculation = QuoteCalculator.calculate(
            laborCost: laborCost,
            materialsCost: materialsCost,
            travelCost: travelCost,
            equipmentCost: equipmentCost,
            discount: discount,
            profitMargin: profitMargin,
            taxRate: taxRate
        )
        totalPrice = calculation.totalPrice
        profitEstimate = calculation.profitEstimate
        marginPercentage = calculation.marginPercentage
        updatedAt = .now
    }

    func quoteDetailsText() -> String {
        """
        Service: \(serviceType)
        Labour: \(laborCost)
        Materials: \(materialsCost)
        Travel: \(travelCost)
        Equipment: \(equipmentCost)
        Discount: \(discount)
        Profit margin: \(profitMargin)%
        Tax rate: \(taxRate)%
        Total: \(totalPrice)
        Optional extras: \(optionalExtras)
        """
    }
}
