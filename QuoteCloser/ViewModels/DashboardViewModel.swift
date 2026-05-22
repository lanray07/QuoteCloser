import Foundation

struct DashboardViewModel {
    let clients: [Client]
    let quotes: [Quote]
    let subscriptionPlan: SubscriptionPlan

    var newQuoteRequests: Int {
        clients.filter { client in
            client.quotes.isEmpty || client.quotes.contains { $0.status == .draft }
        }.count
    }

    var quotesSent: Int {
        quotes.filter { [.sent, .viewed, .followUpDue, .accepted, .rejected, .expired].contains($0.status) }.count
    }

    var acceptedQuotes: Int {
        quotes.filter { $0.status == .accepted }.count
    }

    var rejectedQuotes: Int {
        quotes.filter { $0.status == .rejected }.count
    }

    var pendingFollowUps: Int {
        quotes.filter { quote in
            quote.status == .followUpDue || (quote.followUpDate.map { $0 <= Date() } ?? false)
        }.count
    }

    var estimatedPipelineValue: Double {
        quotes
            .filter { ![.accepted, .rejected, .expired].contains($0.status) }
            .reduce(0) { $0 + $1.totalPrice }
    }

    var recentQuotes: [Quote] {
        Array(quotes.sorted { $0.createdAt > $1.createdAt }.prefix(4))
    }
}
