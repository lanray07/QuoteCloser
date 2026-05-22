import SwiftUI

struct SavedTemplatesView: View {
    private let templates: [SavedTemplate] = [
        SavedTemplate(title: "Quote Intro", tone: "Friendly", content: "Thanks for inviting us to quote. I have kept the pricing clear and included optional upgrades separately so you can choose what works best."),
        SavedTemplate(title: "Premium Proposal Intro", tone: "Premium", content: "This proposal is designed to provide a high-quality finish, clear communication, and a professional handover."),
        SavedTemplate(title: "Follow-Up", tone: "Polite", content: "Just checking you received the quote. Happy to answer questions or adjust optional extras before scheduling."),
        SavedTemplate(title: "Discount Reply", tone: "Confident", content: "Rather than cutting quality, I can look at adjusting optional items or phasing the work to better match the budget."),
        SavedTemplate(title: "Acceptance CTA", tone: "Persuasive", content: "To move ahead, reply with approval and we will confirm scheduling, deposit, and next steps.")
    ]

    var body: some View {
        List {
            Section {
                ForEach(templates) { template in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(template.title)
                                .font(.headline)
                            Spacer()
                            Text(template.tone)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Text(template.content)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            } footer: {
                Text("Business plan scaffolding includes saved pricing templates and white-label proposal placeholders. These examples are local starter copy.")
            }
        }
        .navigationTitle("Templates")
    }
}

private struct SavedTemplate: Identifiable {
    let id = UUID()
    let title: String
    let tone: String
    let content: String
}
