import Charts
import SwiftData
import SwiftUI

struct AnalyticsView: View {
    @Query(sort: \Quote.createdAt, order: .reverse) private var quotes: [Quote]

    var body: some View {
        let viewModel = AnalyticsViewModel(quotes: quotes)

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                metricsGrid(viewModel: viewModel)

                if quotes.isEmpty {
                    EmptyStateView(
                        title: "No analytics yet",
                        message: "Analytics will populate once quotes are created and moved through the pipeline.",
                        systemImage: "chart.bar.xaxis"
                    )
                } else {
                    pipelineChart(viewModel: viewModel)
                    servicePerformance(viewModel: viewModel)
                    lostReasons(viewModel: viewModel)
                }
            }
            .padding()
        }
        .navigationTitle("Analytics")
    }

    private func metricsGrid(viewModel: AnalyticsViewModel) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 12)], spacing: 12) {
            AnalyticsMetricTile(title: "Acceptance rate", value: viewModel.acceptanceRate.formatted(.percent.precision(.fractionLength(0))))
            AnalyticsMetricTile(title: "Average quote", value: AppFormatters.currencyString(viewModel.averageQuoteValue))
            AnalyticsMetricTile(title: "Pipeline value", value: AppFormatters.currencyString(viewModel.totalPipelineValue))
            AnalyticsMetricTile(title: "Upsell value", value: AppFormatters.currencyString(viewModel.upsellValueGenerated))
        }
    }

    private func pipelineChart(viewModel: AnalyticsViewModel) -> some View {
        AnalyticsChartCard(title: "Pipeline Value", subtitle: "Total quote value by status") {
            Chart(viewModel.statusValues) { item in
                BarMark(
                    x: .value("Status", item.status),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(.green.gradient)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }

    private func servicePerformance(viewModel: AnalyticsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best-Performing Services")
                .font(.headline)

            if viewModel.bestPerformingServices.isEmpty {
                Text("No service data yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.bestPerformingServices.prefix(5)) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.service)
                                .font(.subheadline.weight(.semibold))
                            Text("\(item.count) quotes")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(AppFormatters.currencyString(item.value))
                            .font(.subheadline.weight(.semibold))
                    }
                    Divider()
                }
            }
        }
        .quoteCloserCard()
    }

    private func lostReasons(viewModel: AnalyticsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lost Quote Reasons")
                .font(.headline)

            if viewModel.lostQuoteReasons.isEmpty {
                Text("Rejected quote reasons will appear here once recorded.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.lostQuoteReasons.prefix(5)) { item in
                    HStack {
                        Text(item.reason)
                        Spacer()
                        Text("\(item.count)")
                            .fontWeight(.semibold)
                    }
                    Divider()
                }
            }
        }
        .quoteCloserCard()
    }
}

private struct AnalyticsMetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.title3.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .quoteCloserCard()
    }
}
