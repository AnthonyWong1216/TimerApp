//
//  TimerSharedComponents.swift
//  IntervalTimer
//
//  Shared components used by all timer display themes.
//

import SwiftUI

// MARK: - Theme Args (shared parameter bundle)

struct ThemeArgs {
    let engine: TimerEngine
    let showControls: Bool
    let isLandscape: Bool
    let onTogglePlay: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onStop: () -> Void
    let onToggleControls: () -> Void
}

// MARK: - Shared Components

/// Shared header showing routine name, stage info, loop count, stage index, and close button.
struct ThemeHeader: View {
    let engine: TimerEngine
    let onStop: () -> Void
    var tint: Color = .white

    var body: some View {
        VStack(spacing: 6) {
            // Row 1: Close (X) button + routine name
            HStack {
                Button(action: onStop) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(tint.opacity(0.6))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }.buttonStyle(.plain)

                Spacer()

                if let session = engine.session {
                    Text(session.configuration.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint.opacity(0.6))
                        .lineLimit(1)
                }

                Spacer()
                // Spacer to balance the X button
                Color.clear.frame(width: 44, height: 44)
            }

            // Row 2: Stage icon + name + stage index + loop count
            if let session = engine.session, let stage = session.currentStage {
                HStack(spacing: 6) {
                    Image(systemName: stage.type.iconName)
                        .foregroundStyle(stage.colorTheme.color)
                    Text(stage.name)
                        .font(.headline)
                        .lineLimit(1)
                }
                .foregroundColor(tint)

                HStack(spacing: 12) {
                    // Stage index
                    Text("\(session.globalStageIndex + 1) / \(session.configuration.totalStages)")
                        .font(.caption)
                        .foregroundStyle(tint.opacity(0.5))

                    // Loop count
                    if let loop = session.configuration.loopDescription(for: session.globalStageIndex) {
                        Label(loop, systemImage: "repeat")
                            .font(.caption.bold())
                            .foregroundStyle(tint.opacity(0.6))
                    }
                }
            }
        }
        .padding(.top, 8)
    }
}

struct ControlButtons: View {
    let session: TimerSession?; let isLandscape: Bool
    let onTogglePlay: () -> Void; let onPrevious: () -> Void
    let onNext: () -> Void; let onStop: () -> Void

    var body: some View {
        HStack(spacing: isLandscape ? 40 : 28) {
            btn("backward.fill", action: onPrevious)
            Button(action: onTogglePlay) {
                Image(systemName: session?.state == .running ? "pause.fill" : "play.fill")
                    .font(.system(size: 36)).frame(width: 72, height: 72)
                    .background(Circle().fill(.white.opacity(0.15))).contentShape(Circle())
            }
            btn("forward.fill", action: onNext)
            btn("stop.fill", action: onStop)
        }.foregroundColor(.white.opacity(0.95))
    }
    private func btn(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon).font(.title2).frame(width: 52, height: 52).contentShape(Rectangle())
        }
    }
}

struct NextLabel: View {
    let session: TimerSession?; var fg: Color = .white.opacity(0.7)
    var body: some View {
        if let n = session?.nextStage {
            HStack(spacing: 6) {
                Image(systemName: n.type.iconName).foregroundStyle(n.colorTheme.color)
                Text(NSLocalizedString("timer.next", comment: ""))
                Text(n.name); Text(n.formattedDuration).monospacedDigit()
            }.font(.subheadline).foregroundStyle(fg)
        }
    }
}

/// Thin overall workout progress bar displayed above the controls.
struct OverallProgressBar: View {
    let session: TimerSession?
    var tint: Color = .white

    var body: some View {
        let p = session?.overallProgress ?? 0
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(0.15))
                Capsule().fill(tint.opacity(0.5))
                    .frame(width: geo.size.width * min(CGFloat(p), 1))
                    .animation(.linear(duration: 0.2), value: p)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
    }
}

func stageColor(_ e: TimerEngine) -> Color {
    e.session?.currentStage?.colorTheme.color ?? .gray
}
