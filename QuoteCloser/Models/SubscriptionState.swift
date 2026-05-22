import Foundation
import SwiftData

@Model
final class SubscriptionState: Identifiable {
    @Attribute(.unique) var id: UUID
    var planRaw: String
    var isActive: Bool
    var renewsAt: Date?
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan = .free,
        isActive: Bool = false,
        renewsAt: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.planRaw = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
        self.updatedAt = updatedAt
    }

    var plan: SubscriptionPlan {
        get { SubscriptionPlan(rawValue: planRaw) ?? .free }
        set {
            planRaw = newValue.rawValue
            updatedAt = .now
        }
    }
}
