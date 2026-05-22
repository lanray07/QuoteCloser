import Foundation
import UIKit

struct PDFProposalRenderer {
    func render(
        proposal: Proposal,
        quote: Quote,
        businessProfile: BusinessProfile?,
        client: Client?
    ) throws -> URL {
        let fileName = sanitizedFileName("\(client?.name ?? "Client")-\(proposal.title)-\(quote.id.uuidString.prefix(6)).pdf")
        let outputURL = try outputDirectory().appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: outputURL) { context in
            var y: CGFloat = 54
            let margin: CGFloat = 54
            let width = pageRect.width - margin * 2

            func beginPageIfNeeded(height: CGFloat) {
                if y + height > pageRect.height - 64 {
                    context.beginPage()
                    y = 54
                }
            }

            func drawText(
                _ text: String,
                font: UIFont,
                color: UIColor = .label,
                spacing: CGFloat = 12
            ) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineSpacing = 3
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]
                let box = (text as NSString).boundingRect(
                    with: CGSize(width: width, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                beginPageIfNeeded(height: ceil(box.height) + spacing)
                (text as NSString).draw(
                    with: CGRect(x: margin, y: y, width: width, height: ceil(box.height)),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                y += ceil(box.height) + spacing
            }

            func section(_ title: String, _ body: String) {
                drawText(title, font: .boldSystemFont(ofSize: 15), color: .secondaryLabel, spacing: 6)
                drawText(body.isEmpty ? "To be confirmed." : body, font: .systemFont(ofSize: 12), spacing: 16)
            }

            context.beginPage()
            drawText("QuoteCloser Proposal", font: .boldSystemFont(ofSize: 28), spacing: 6)
            drawText(proposal.title, font: .systemFont(ofSize: 16), color: .secondaryLabel, spacing: 24)

            section(
                "Business Details",
                """
                \(display(businessProfile?.businessName, fallback: "Your Business"))
                \(display(businessProfile?.phone))
                \(display(businessProfile?.email))
                \(display(businessProfile?.address))
                """
            )

            section(
                "Client Details",
                """
                \(display(client?.name, fallback: "Client"))
                \(display(client?.phone))
                \(display(client?.email))
                \(display(client?.address))
                """
            )

            section("Quote Summary", proposal.content)

            section(
                "Price Breakdown",
                """
                Labour: \(AppFormatters.currencyString(quote.laborCost))
                Materials: \(AppFormatters.currencyString(quote.materialsCost))
                Travel: \(AppFormatters.currencyString(quote.travelCost))
                Equipment: \(AppFormatters.currencyString(quote.equipmentCost))
                Discount: \(AppFormatters.currencyString(quote.discount))
                Profit estimate: \(AppFormatters.currencyString(quote.profitEstimate))
                Tax placeholder: \(quote.taxRate.formatted(.number.precision(.fractionLength(0...2))))%
                Total price: \(AppFormatters.currencyString(quote.totalPrice))
                """
            )

            let selectedUpsells = quote.upsells
                .filter(\.selected)
                .map { "- \($0.title): \(AppFormatters.currencyString($0.estimatedValue))" }
                .joined(separator: "\n")
            section("Optional Extras", selectedUpsells.isEmpty ? "No optional extras selected." : selectedUpsells)

            section(
                "Terms",
                """
                Prices are estimates until reviewed and approved by the business. Scope changes, hidden defects, third-party fees, permits, or additional materials may affect the final price.
                """
            )

            section(
                "Acceptance",
                """
                Client signature:


                Date:
                """
            )

            section(
                "Disclaimer",
                """
                AI content should be reviewed. Pricing estimates are not guaranteed. This proposal is not legal or financial advice. The user is responsible for final contracts and pricing.
                """
            )
        }

        return outputURL
    }

    private func outputDirectory() throws -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("QuoteCloserPDFs", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func sanitizedFileName(_ input: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " -_()."))
        let clean = input.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        return String(clean).replacingOccurrences(of: " ", with: "-")
    }

    private func display(_ value: String?, fallback: String = "") -> String {
        value?.nonEmptyValue ?? fallback
    }
}
