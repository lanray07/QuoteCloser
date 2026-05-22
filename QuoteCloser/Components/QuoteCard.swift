import SwiftUI

struct QuoteCard: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quote.serviceType.nonEmptyValue ?? "Untitled quote")
                        .font(.headline)
                    Text(quote.client?.name.nonEmptyValue ?? "No client attached")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                QuoteStatusBadge(status: quote.status)
            }

            HStack {
                Label(AppFormatters.currencyString(quote.totalPrice), systemImage: "sterlingsign.circle")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text("Margin \(quote.marginPercentage.formatted(.number.precision(.fractionLength(0...1))))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let followUpDate = quote.followUpDate {
                Label("Follow up \(AppFormatters.dateString(followUpDate))", systemImage: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .quoteCloserCard()
    }
}
