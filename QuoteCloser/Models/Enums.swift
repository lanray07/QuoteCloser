import Foundation

enum BusinessType: String, CaseIterable, Codable, Hashable, Identifiable {
    case roofer
    case landscaper
    case cleaner
    case plumber
    case electrician
    case decorator
    case drivewayInstaller
    case agency
    case freelancer
    case localServiceBusiness

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .roofer: "Roofer"
        case .landscaper: "Landscaper"
        case .cleaner: "Cleaner"
        case .plumber: "Plumber"
        case .electrician: "Electrician"
        case .decorator: "Decorator"
        case .drivewayInstaller: "Driveway Installer"
        case .agency: "Agency"
        case .freelancer: "Freelancer"
        case .localServiceBusiness: "Local Service Business"
        }
    }
}

enum MainGoal: String, CaseIterable, Codable, Hashable, Identifiable {
    case sendQuotesFaster
    case closeMoreJobs
    case improveProposals
    case followUpBetter
    case increaseAverageOrderValue

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sendQuotesFaster: "Send quotes faster"
        case .closeMoreJobs: "Close more jobs"
        case .improveProposals: "Improve proposals"
        case .followUpBetter: "Follow up better"
        case .increaseAverageOrderValue: "Increase average order value"
        }
    }
}

enum LeadUrgency: String, CaseIterable, Codable, Hashable, Identifiable {
    case low
    case standard
    case urgent
    case emergency

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .standard: "Standard"
        case .urgent: "Urgent"
        case .emergency: "Emergency"
        }
    }
}

enum QuoteStatus: String, CaseIterable, Codable, Hashable, Identifiable {
    case draft
    case sent
    case viewed
    case followUpDue
    case accepted
    case rejected
    case expired

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .draft: "Draft"
        case .sent: "Sent"
        case .viewed: "Viewed"
        case .followUpDue: "Follow-up due"
        case .accepted: "Accepted"
        case .rejected: "Rejected"
        case .expired: "Expired"
        }
    }
}

enum ToneOption: String, CaseIterable, Codable, Hashable, Identifiable {
    case friendly
    case premium
    case confident
    case polite
    case persuasive

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

enum ObjectionType: String, CaseIterable, Codable, Hashable, Identifiable {
    case tooExpensive
    case needToThink
    case competitorCheaper
    case sooner
    case discount
    case moreDetails

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .tooExpensive: "too expensive"
        case .needToThink: "I need to think about it"
        case .competitorCheaper: "another company is cheaper"
        case .sooner: "can you do it sooner?"
        case .discount: "can I get a discount?"
        case .moreDetails: "send me more details"
        }
    }

    var displayName: String {
        switch self {
        case .tooExpensive: "Too expensive"
        case .needToThink: "Need to think"
        case .competitorCheaper: "Competitor is cheaper"
        case .sooner: "Needs it sooner"
        case .discount: "Asked for discount"
        case .moreDetails: "Needs more details"
        }
    }
}

enum FollowUpKind: String, CaseIterable, Codable, Hashable, Identifiable {
    case sms
    case email
    case whatsApp
    case reminder
    case finalCheckIn
    case reviewRequest

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sms: "SMS follow-up"
        case .email: "Email follow-up"
        case .whatsApp: "WhatsApp-style message"
        case .reminder: "Reminder follow-up"
        case .finalCheckIn: "Final check-in"
        case .reviewRequest: "Review request"
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Codable, Hashable, Identifiable {
    case free
    case proMonthly
    case proYearly
    case businessMonthly

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .proMonthly: "Pro Monthly"
        case .proYearly: "Pro Yearly"
        case .businessMonthly: "Business Monthly"
        }
    }

    var placeholderPrice: String {
        switch self {
        case .free: "\u{00A3}0"
        case .proMonthly: "\u{00A3}19.99"
        case .proYearly: "\u{00A3}149.99"
        case .businessMonthly: "\u{00A3}79.99"
        }
    }
}
