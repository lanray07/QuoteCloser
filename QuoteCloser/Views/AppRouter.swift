import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    var path: [AppRoute] = []

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path.removeAll()
    }
}

enum AppRoute: Hashable {
    case clientDetails(UUID?)
    case quoteBuilder(UUID?)
    case quoteDetail(UUID)
    case proposalGenerator(UUID?)
    case objectionHandler(UUID?)
    case followUpWriter(UUID?)
    case upsellEngine
    case voiceToQuote
    case savedTemplates
    case paywall
}
