import SwiftUI

struct ProposalCard: View {
    let proposal: Proposal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(proposal.title, systemImage: "doc.richtext")
                    .font(.headline)
                Spacer()
                Text(AppFormatters.dateString(proposal.createdAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(proposal.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(5)
        }
        .quoteCloserCard()
    }
}
