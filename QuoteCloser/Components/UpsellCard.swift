import SwiftUI

struct UpsellCard: View {
    let title: String
    let description: String
    let estimatedValue: Double
    let isSelected: Bool
    var onToggle: (() -> Void)?

    var body: some View {
        Button {
            onToggle?()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .green : .accentColor)
                    .frame(width: 26)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(AppFormatters.currencyString(estimatedValue))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.accentColor)
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(onToggle == nil)
        .quoteCloserCard()
    }
}
