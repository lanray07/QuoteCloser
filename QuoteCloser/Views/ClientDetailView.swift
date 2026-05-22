import SwiftData
import SwiftUI

struct ClientDetailView: View {
    let client: Client?

    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router

    @State private var name: String
    @State private var phone: String
    @State private var email: String
    @State private var address: String
    @State private var serviceRequested: String
    @State private var budgetRange: String
    @State private var urgency: LeadUrgency
    @State private var notes: String
    @State private var errorMessage: String?

    init(client: Client? = nil) {
        self.client = client
        _name = State(initialValue: client?.name ?? "")
        _phone = State(initialValue: client?.phone ?? "")
        _email = State(initialValue: client?.email ?? "")
        _address = State(initialValue: client?.address ?? "")
        _serviceRequested = State(initialValue: client?.serviceRequested ?? "")
        _budgetRange = State(initialValue: client?.budgetRange ?? "")
        _urgency = State(initialValue: client?.urgency ?? .standard)
        _notes = State(initialValue: client?.notes ?? "")
    }

    var body: some View {
        Form {
            if let errorMessage {
                Section {
                    ErrorBanner(message: errorMessage)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }

            Section("Client") {
                TextField("Client name", text: $name)
                    .textContentType(.name)
                TextField("Phone", text: $phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                TextField("Address", text: $address, axis: .vertical)
                    .textContentType(.fullStreetAddress)
                    .lineLimit(2...4)
            }

            Section("Lead Details") {
                TextField("Service requested", text: $serviceRequested, axis: .vertical)
                    .lineLimit(1...3)
                TextField("Budget range", text: $budgetRange)
                Picker("Urgency", selection: $urgency) {
                    ForEach(LeadUrgency.allCases) { urgency in
                        Text(urgency.displayName).tag(urgency)
                    }
                }
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(4...8)
            }

            Section {
                Button {
                    continueToQuote()
                } label: {
                    Label("Continue to Quote Builder", systemImage: "arrow.right.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle(client == nil ? "New Lead" : "Lead Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    _ = saveClient()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    @discardableResult
    private func saveClient() -> Client? {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Add a client name before saving."
            return nil
        }

        let target = client ?? Client()
        target.name = name
        target.phone = phone
        target.email = email
        target.address = address
        target.serviceRequested = serviceRequested
        target.budgetRange = budgetRange
        target.urgency = urgency
        target.notes = notes
        target.updatedAt = .now

        if client == nil {
            modelContext.insert(target)
        }

        do {
            try modelContext.save()
            errorMessage = nil
            return target
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    private func continueToQuote() {
        guard let savedClient = saveClient() else { return }
        router.navigate(to: .quoteBuilder(savedClient.id))
    }
}
