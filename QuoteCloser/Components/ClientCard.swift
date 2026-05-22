import SwiftUI

struct ClientCard: View {
    let client: Client

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(client.name.nonEmptyValue ?? "Unnamed lead")
                        .font(.headline)
                    Text(client.serviceRequested.nonEmptyValue ?? "Service not set")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(client.urgency.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }

            if let address = client.address.nonEmptyValue {
                Label(address, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                if let phone = client.phone.nonEmptyValue {
                    Label(phone, systemImage: "phone")
                }
                if let email = client.email.nonEmptyValue {
                    Label(email, systemImage: "envelope")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .quoteCloserCard()
    }
}
