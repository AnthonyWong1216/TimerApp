//
//  ThemeFullScreen.swift
//  IntervalTimer
//
//  Theme B: Full Screen colour shift.
//

import SwiftUI

struct ThemeFullScreen: View {
    let a: ThemeArgs
    @AppStorage("timerNumberFont") private var fontKey = TimerNumberFont.rounded.rawValue
    private var font: TimerNumberFont { TimerNumberFont(rawValue: fontKey) ?? .rounded }

    var body: some View {
        let color = stageColor(a.engine)
        let t = a.engine.session?.formattedTimeRemaining ?? "00:00"
        let p = a.engine.session?.stageProgress ?? 0
        let rem = a.engine.session?.timeRemaining ?? 99

        ZStack {
            LinearGradient(colors: [color.opacity(0.6), color.opacity(0.15), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea().animation(.easeInOut(duration: 0.5), value: color)
                .onTapGesture { a.onToggleControls() }

            VStack(spacing: 0) {
                ThemeHeader(engine: a.engine, onStop: a.onStop)
                    .opacity(a.showControls ? 1 : 0)
                Spacer()
                if let s = a.engine.session?.currentStage {
                    Image(systemName: s.type.iconName).font(.system(size: 44))
                        .foregroundStyle(s.colorTheme.color).padding(.bottom, 4)
                    Text(s.type.localizedName.uppercased()).font(.caption.weight(.bold))
                        .tracking(4).foregroundStyle(.white.opacity(0.6))
                }
                timerDigitsView(text: t, font: font, size: a.isLandscape ? 80 : 110, color: .white, weight: .heavy)
                    .scaleEffect(rem <= 5 ? 1.08 : 1.0).animation(.easeInOut(duration: 0.4), value: rem <= 5)
                    .padding(.vertical, 8)
                ProgressView(value: p)
                    .progressViewStyle(.linear)
                    .tint(color)
                    .padding(.horizontal, 40)
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
}
