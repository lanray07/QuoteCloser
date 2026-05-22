import Foundation

struct StatusValue: Identifiable {
    let id = UUID()
    let status: String
    let value: Double
}

struct ServicePerformance: Identifiable {
    let id = UUID()
    let service: String
    let count: Int
    let value: Double
}

struct LostReasonMetric: Identifiable {
    let id = UUID()
    let reason: String
    let count: Int
}

struct AnalyticsViewModel {
    let quotes: [Quote]

    var acceptanceRate: Double {
        let decided = quotes.filter { [.accepted, .rejected].contains($0.status) }
        guard !decided.isEmpty else { return 0 }
        return Double(decided.filter { $0.status == .accepted }.count) / Double(decided.count)
    }

    var averageQuoteValue: Double {
        guard !quotes.isEmpty else { return 0 }
        return quotes.reduce(0) { $0 + $1.totalPrice } / Double(quotes.count)
    }

    var totalPipelineValue: Double {
        quotes
            .filter { ![.accepted, .rejected, .expired].contains($0.status) }
            .reduce(0) { $0 + $1.totalPrice }
    }

    var upsellValueGenerated: Double {
        quotes.reduce(0) { total, quote in
            total + quote.upsells.filter(\.selected).reduce(0) { $0 + $1.estimatedValue }
        }
    }

    var statusValues: [StatusValue] {
        QuoteStatus.allCases.map { status in
            StatusValue(
                status: status.displayName,
                value: quotes.filter { $0.status == status }.reduce(0) { $0 + $1.totalPrice }
            )
        }
    }

    var bestPerformingServices: [ServicePerformance] {
        let grouped = Dictionary(grouping: quotes) { quote in
            quote.serviceType.nonEmptyValue ?? "Unspecified"
        }
        return grouped.map { service, quotes in
            ServicePerformance(
                service: service,
                count: quotes.count,
                value: quotes.reduce(0) { $0 + $1.totalPrice }
            )
        }
        .sorted { $0.value > $1.value }
    }

    var lostQuoteReasons: [LostReasonMetric] {
        let rejected = quotes.filter { $0.status == .rejected }
        let grouped = Dictionary(grouping: rejected) { quote in
            quote.lostReason.nonEmptyValue ?? "No reason recorded"
        }
        return grouped.map { reason, quotes in
            LostReasonMetric(reason: reason, count: quotes.count)
        }
        .sorted { $0.count > $1.count }
    }
}
