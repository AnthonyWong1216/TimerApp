import SwiftUI

struct WatchTimerView: View {
    @EnvironmentObject private var timerStore: WatchTimerStore

    var body: some View {
        let timer = timerStore.snapshot

        ScrollView {
            VStack(spacing: 10) {
                Text(timer.routineName)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)

                if timer.isConnected, !timer.stageName.isEmpty {
                    if !timer.loopDescription.isEmpty {
                        Label(timer.loopDescription, systemImage: "repeat")
                            .font(.caption.bold())
                            .foregroundStyle(.cyan)
                    }

                    Text(timer.stageType)
                        .font(.headline)
                    Text(timer.stageName)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Text(timer.formattedTime)
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    Button {
                        timerStore.send(timer.isRunning ? "pause" : "resume")
                    } label: {
                        Label(
                            timer.isRunning
                                ? NSLocalizedString("watch.pause", comment: "Pause")
                                : NSLocalizedString("watch.continue", comment: "Continue"),
                            systemImage: timer.isRunning ? "pause.fill" : "play.fill"
                        )
                    }
                    .tint(timer.isRunning ? .orange : .green)

                    HStack {
                        Button { timerStore.send("previous") } label: {
                            Image(systemName: "backward.fill")
                        }
                        .disabled(timer.stageIndex == 0)

                        Button { timerStore.send("next") } label: {
                            Image(systemName: "forward.fill")
                        }
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        timerStore.send("stop")
                    } label: {
                        Label(
                            NSLocalizedString("watch.stop", comment: "Stop"),
                            systemImage: "stop.fill"
                        )
                    }
                    .buttonStyle(.bordered)
                } else {
                    Image(systemName: "iphone.and.arrow.forward")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(NSLocalizedString("watch.start_on_iphone", comment: "Start a routine on iPhone"))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}