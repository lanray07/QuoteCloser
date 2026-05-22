import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .quoteCloserCard()
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.callout)
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .quoteCloserCard()
    }
}

struct DisclaimerNotice: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Review before sending", systemImage: "checkmark.shield")
                .font(.headline)
            Text("AI content should be reviewed. Pricing estimates are not guaranteed. QuoteCloser is not legal or financial advice. You are responsible for final contracts and pricing.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .quoteCloserCard()
    }
}

struct LoadingButton: View {
    let title: String
    let systemImage: String
    let isLoading: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isLoading)
    }
}
