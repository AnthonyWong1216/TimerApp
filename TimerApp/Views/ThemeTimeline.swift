//
//  ThemeTimeline.swift
//  IntervalTimer
//
//  Theme C: Timeline with segmented stage bar.
//

import SwiftUI

struct ThemeTimeline: View {
    let a: ThemeArgs
    @AppStorage("timerNumberFont") private var fontKey = TimerNumberFont.rounded.rawValue
    private var font: TimerNumberFont { TimerNumberFont(rawValue: fontKey) ?? .rounded }

    var body: some View {
        let color = stageColor(a.engine)
        let t = a.engine.session?.formattedTimeRemaining ?? "00:00"
        let p = a.engine.session?.stageProgress ?? 0
        let sz: CGFloat = a.isLandscape ? 170 : 220

        ZStack {
            Color.black.ignoresSafeArea()
                .onTapGesture { a.onToggleControls() }
            VStack(spacing: 0) {
                ThemeHeader(engine: a.engine, onStop: a.onStop)
                    .opacity(a.showControls ? 1 : 0)
                Spacer()
                ZStack {
                    Circle().stroke(color.opacity(0.15), lineWidth: 10)
                    Circle().trim(from: 0, to: CGFloat(p))
                        .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90)).animation(.linear(duration: 0.1), value: p)
                    timerDigitsView(text: t, font: font, size: a.isLandscape ? 44 : 56, color: .white)
                }.frame(width: sz, height: sz)
                Spacer()
                tlBar.padding(.horizontal, 20).padding(.bottom, 16)
                NextLabel(session: a.engine.session).padding(.bottom, 6)
                OverallProgressBar(session: a.engine.session, tint: color).padding(.bottom, 12)
                ControlButtons(session: a.engine.session, isLandscape: a.isLandscape,
                               onTogglePlay: a.onTogglePlay, onPrevious: a.onPrevious,
                               onNext: a.onNext, onStop: a.onStop)
                    .opacity(a.showControls ? 1 : 0).padding(.bottom, 20)
            }.padding()
        }
    }

    private var tlBar: some View {
        GeometryReader { geo in
            let stages = a.engine.session?.configuration.expandedStages ?? []
            let total = a.engine.session?.configuration.totalDuration ?? 1
            let cur = a.engine.session?.globalStageIndex ?? 0
            HStack(spacing: 2) {
                ForEach(Array(stages.enumerated()), id: \.offset) { idx, stage in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(stage.colorTheme.color.opacity(idx == cur ? 1.0 : 0.3))
                        .frame(width: max(4, geo.size.width * CGFloat(stage.duration / max(total, 1)) - 2))
                }
            }
        }.frame(height: 12)
    }
}
