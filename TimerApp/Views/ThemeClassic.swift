//
//  ThemeClassic.swift
//  IntervalTimer
//
//  Theme A: Classic refined ring.
//

import SwiftUI

struct ThemeClassic: View {
    let a: ThemeArgs
    @AppStorage("timerNumberFont") private var fontKey = TimerNumberFont.rounded.rawValue
    private var font: TimerNumberFont { TimerNumberFont(rawValue: fontKey) ?? .rounded }

    var body: some View {
        let color = stageColor(a.engine)
        ZStack {
            LinearGradient(colors: [color.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture { a.onToggleControls() }
            VStack(spacing: 0) {
                ThemeHeader(engine: a.engine, onStop: a.onStop)
                    .opacity(a.showControls ? 1 : 0)
                Spacer()
                ring(color: color)
                Spacer()
                NextLabel(session: a.engine.session).padding(.bottom, 6)
                OverallProgressBar(session: a.engine.session, tint: color).padding(.bottom, 12)
                ControlButtons(session: a.engine.session, isLandscape: a.isLandscape,
                               onTogglePlay: a.onTogglePlay, onPrevious: a.onPrevious,
                               onNext: a.onNext, onStop: a.onStop)
                    .opacity(a.showControls ? 1 : 0).padding(.bottom, 20)
            }.padding()
        }
    }

    private func ring(color: Color) -> some View {
        let p = a.engine.session?.stageProgress ?? 0
        let t = a.engine.session?.formattedTimeRemaining ?? "00:00"
        let sz: CGFloat = a.isLandscape ? 200 : 280
        return ZStack {
            Circle().stroke(color.opacity(0.2), lineWidth: 14)
            Circle().trim(from: 0, to: CGFloat(p))
                .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90)).animation(.linear(duration: 0.1), value: p)
            timerDigitsView(text: t, font: font, size: a.isLandscape ? 52 : 72, color: .white)
        }.frame(width: sz, height: sz)
    }
}
