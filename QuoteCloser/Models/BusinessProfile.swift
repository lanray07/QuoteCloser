import Foundation
import SwiftData

@Model
final class BusinessProfile: Identifiable {
    @Attribute(.unique) var id: UUID
    var businessName: String
    var ownerName: String
    var email: String
    var phone: String
    var address: String
    var website: String
    var businessTypeRaw: String
    var mainGoalRaw: String
    var mockAIEnabled: Bool
    var remoteAIConsentGranted: Bool = false
    var isOnboardingComplete: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        businessName: String = "",
        ownerName: String = "",
        email: String = "",
        phone: String = "",
        address: String = "",
        website: String = "",
        businessType: BusinessType = .localServiceBusiness,
        mainGoal: MainGoal = .sendQuotesFaster,
        mockAIEnabled: Bool = true,
        remoteAIConsentGranted: Bool = false,
        isOnboardingComplete: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.businessName = businessName
        self.ownerName = ownerName
        self.email = email
        self.phone = phone
        self.address = address
        self.website = website
        self.businessTypeRaw = businessType.rawValue
        self.mainGoalRaw = mainGoal.rawValue
        self.mockAIEnabled = mockAIEnabled
        self.remoteAIConsentGranted = remoteAIConsentGranted
        self.isOnboardingComplete = isOnboardingComplete
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var businessType: BusinessType {
        get { BusinessType(rawValue: businessTypeRaw) ?? .localServiceBusiness }
        set {
            businessTypeRaw = newValue.rawValue
            updatedAt = .now
        }
    }

    var mainGoal: MainGoal {
        get { MainGoal(rawValue: mainGoalRaw) ?? .sendQuotesFaster }
        set {
            mainGoalRaw = newValue.rawValue
            updatedAt = .now
        }
    }
}
