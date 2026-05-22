import Foundation

extension AIRequestContext {
    static func make(
        quote: Quote?,
        client: Client?,
        profile: BusinessProfile?,
        tone: ToneOption? = nil,
        extraNotes: String = ""
    ) -> AIRequestContext {
        let quoteDetails = quote?.quoteDetailsText() ?? "No quote pricing has been added yet."
        let notes = [
            client?.notes,
            client?.serviceRequested,
            client?.budgetRange.isEmpty == false ? "Budget range: \(client?.budgetRange ?? "")" : nil,
            client.map { "Urgency: \($0.urgency.displayName)" },
            extraNotes.isEmpty ? nil : extraNotes
        ]
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined(separator: "\n")

        return AIRequestContext(
            businessType: profile?.businessType ?? .localServiceBusiness,
            serviceType: quote?.serviceType.nonEmptyValue ?? client?.serviceRequested.nonEmptyValue ?? "",
            clientName: client?.name ?? "",
            clientNotes: notes,
            quoteDetails: quoteDetails,
            tone: tone
        )
    }
}

extension String {
    var nonEmptyValue: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
