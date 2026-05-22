import SwiftUI

struct FollowUpCard: View {
    let followUp: FollowUpMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(followUp.type.displayName, systemImage: "paperplane")
                    .font(.headline)
                Spacer()
                Text(followUp.tone.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text(followUp.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .quoteCloserCard()
    }
}
