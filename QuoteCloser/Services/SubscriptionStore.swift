import Foundation
import Observation
import StoreKit

enum StoreError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            "StoreKit could not verify this transaction."
        }
    }
}

@MainActor
@Observable
final class SubscriptionStore {
    static let productIDs: Set<String> = [
        "quotecloser.pro.monthly",
        "quotecloser.pro.yearly",
        "quotecloser.business.monthly"
    ]

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?
    @ObservationIgnored private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { [weak self] in
            await self?.listenForTransactions()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var currentPlan: SubscriptionPlan {
        if purchasedProductIDs.contains("quotecloser.business.monthly") {
            return .businessMonthly
        }
        if purchasedProductIDs.contains("quotecloser.pro.yearly") {
            return .proYearly
        }
        if purchasedProductIDs.contains("quotecloser.pro.monthly") {
            return .proMonthly
        }
        return .free
    }

    var isActive: Bool {
        currentPlan != .free
    }

    func product(for plan: SubscriptionPlan) -> Product? {
        let id: String
        switch plan {
        case .free:
            return nil
        case .proMonthly:
            id = "quotecloser.pro.monthly"
        case .proYearly:
            id = "quotecloser.pro.yearly"
        case .businessMonthly:
            id = "quotecloser.business.monthly"
        }
        return products.first { $0.id == id }
    }

    func loadProducts() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: Self.productIDs).sorted { $0.displayName < $1.displayName }
            await refreshEntitlements()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var activeIDs = Set<String>()
        for await entitlement in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(entitlement) else { continue }
            guard transaction.revocationDate == nil else { continue }
            if let expirationDate = transaction.expirationDate, expirationDate < Date() { continue }
            activeIDs.insert(transaction.productID)
        }
        purchasedProductIDs = activeIDs
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            guard let transaction = try? checkVerified(update) else { continue }
            await refreshEntitlements()
            await transaction.finish()
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified(_, _):
            throw StoreError.failedVerification
        }
    }
}
