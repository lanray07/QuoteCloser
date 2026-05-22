import Foundation

struct QuoteCalculation: Equatable {
    let subtotal: Double
    let discount: Double
    let profitEstimate: Double
    let taxableAmount: Double
    let taxAmount: Double
    let totalPrice: Double
    let marginPercentage: Double
}

enum QuoteCalculator {
    static func calculate(
        laborCost: Double,
        materialsCost: Double,
        travelCost: Double,
        equipmentCost: Double,
        discount: Double,
        profitMargin: Double,
        taxRate: Double
    ) -> QuoteCalculation {
        let subtotal = max(0, laborCost) + max(0, materialsCost) + max(0, travelCost) + max(0, equipmentCost)
        let discountAmount = min(max(0, discount), subtotal)
        let profitEstimate = max(0, subtotal - discountAmount) * max(0, profitMargin) / 100
        let taxableAmount = max(0, subtotal - discountAmount + profitEstimate)
        let taxAmount = taxableAmount * max(0, taxRate) / 100
        let totalPrice = taxableAmount + taxAmount
        let marginPercentage = totalPrice > 0 ? profitEstimate / totalPrice * 100 : 0

        return QuoteCalculation(
            subtotal: subtotal,
            discount: discountAmount,
            profitEstimate: profitEstimate,
            taxableAmount: taxableAmount,
            taxAmount: taxAmount,
            totalPrice: totalPrice,
            marginPercentage: marginPercentage
        )
    }
}
