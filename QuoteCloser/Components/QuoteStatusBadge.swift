import SwiftUI

struct QuoteStatusBadge: View {
    let status: QuoteStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .foregroundStyle(color)
            .background(color.opacity(0.13), in: Capsule())
            .accessibilityLabel("Quote status \(status.displayName)")
    }

    private var color: Color {
        switch status {
        case .draft: .secondary
        case .sent: .blue
        case .viewed: .indigo
        case .followUpDue: .orange
        case .accepted: .green
        case .rejected: .red
        case .expired: .gray
        }
    }
}
