import SwiftData
import SwiftUI

struct VoiceToQuoteView: View {
    @Environment(\.aiService) private var aiService
    @Environment(AppRouter.self) private var router
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]

    @StateObject private var speechService = SpeechRecognitionService()
    @State private var viewModel = VoiceToQuoteViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Voice Notes")
                        .font(.headline)
                    Text(speechService.transcript.isEmpty ? "Record site notes, client requirements, objections, measurements, and pricing clues." : speechService.transcript)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .foregroundStyle(speechService.transcript.isEmpty ? .secondary : .primary)

                    HStack {
                        Button {
                            toggleRecording()
                        } label: {
                            Label(speechService.isRecording ? "Stop" : "Record", systemImage: speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(speechService.authorizationStatus != .authorized)

                        Button {
                            speechService.transcript = ""
                        } label: {
                            Label("Clear", systemImage: "xmark.circle")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .quoteCloserCard()

                if let error = speechService.errorMessage ?? viewModel.errorMessage {
                    ErrorBanner(message: error)
                }

                LoadingButton(
                    title: "Summarize Into Quote Notes",
                    systemImage: "sparkles",
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.summarize(
                            transcript: speechService.transcript,
                            profile: profiles.first,
                            aiService: aiService
                        )
                    }
                }

                if viewModel.summary.isEmpty {
                    EmptyStateView(
                        title: "No summary yet",
                        message: "Record a note, then summarize it into quote-ready details.",
                        systemImage: "waveform"
                    )
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(viewModel.summary)
                            .textSelection(.enabled)
                        Button {
                            router.navigate(to: .clientDetails(nil))
                        } label: {
                            Label("Create Lead", systemImage: "person.badge.plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .quoteCloserCard()
                }

                DisclaimerNotice()
            }
            .padding()
        }
        .navigationTitle("Voice-to-Quote")
        .task {
            await speechService.requestAuthorization()
        }
    }

    private func toggleRecording() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            do {
                try speechService.startRecording()
            } catch {
                speechService.errorMessage = error.localizedDescription
            }
        }
    }
}
