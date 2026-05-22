import SwiftData
import SwiftUI

struct AIWorkbenchView: View {
    @Environment(AppRouter.self) private var router
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    var body: some View {
        List {
            Section {
                toolRow("Proposal Generator", icon: "doc.richtext", route: .proposalGenerator(quotes.first?.id))
                toolRow("Upsell Engine", icon: "arrow.up.right.circle", route: .upsellEngine)
                toolRow("Objection Handler", icon: "quote.bubble", route: .objectionHandler(quotes.first?.id))
                toolRow("Follow-Up Writer", icon: "paperplane", route: .followUpWriter(quotes.first?.id))
                toolRow("Voice-to-Quote", icon: "waveform", route: .voiceToQuote)
            }

            Section {
                DisclaimerNotice()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("AI Tools")
    }

    private func toolRow(_ title: String, icon: String, route: AppRoute) -> some View {
        Button {
            router.navigate(to: route)
        } label: {
            Label(title, systemImage: icon)
        }
    }
}
