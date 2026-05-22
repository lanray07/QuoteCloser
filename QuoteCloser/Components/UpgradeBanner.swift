import SwiftUI

struct UpgradeBanner: View {
    var action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 3) {
                Text("Unlock AI closing tools")
                    .font(.headline)
                Text("Unlimited quotes, AI proposals, follow-ups, pipeline and analytics.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Upgrade", action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .quoteCloserCard()
    }
}
