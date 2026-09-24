//
//  ThemeHourglass.swift
//  IntervalTimer
//
//  Theme E: Hourglass with Canvas-drawn sand timer.
//

import SwiftUI

struct ThemeHourglass: View {
    let a: ThemeArgs
    @AppStorage("timerNumberFont") private var fontKey = TimerNumberFont.rounded.rawValue
    private var font: TimerNumberFont { TimerNumberFont(rawValue: fontKey) ?? .rounded }

    var body: some View {
        let color = stageColor(a.engine)
        let t = a.engine.session?.formattedTimeRemaining ?? "00:00"
        let p = a.engine.session?.stageProgress ?? 0
        let rem = a.engine.session?.timeRemaining ?? 99

        ZStack {
            LinearGradient(colors: [Color(red: 0.08, green: 0.06, blue: 0.12),
                                     Color(red: 0.02, green: 0.02, blue: 0.04)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .onTapGesture { a.onToggleControls() }

            VStack(spacing: 0) {
                ThemeHeader(engine: a.engine, onStop: a.onStop, tint: color)
                    .opacity(a.showControls ? 1 : 0)
                Spacer()
                HourglassCanvas(progress: p, sandColor: color)
                    .frame(width: a.isLandscape ? 140 : 180,
                           height: a.isLandscape ? 200 : 280)
                    .padding(.bottom, 16)
                timerDigitsView(text: t, font: font, size: a.isLandscape ? 56 : 72, color: color)
                    .scaleEffect(rem <= 5 ? 1.06 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: rem <= 5)
                    .padding(.top, 8)
                Spacer()
                NextLabel(session: a.engine.session, fg: color.opacity(0.7))
                    .padding(.bottom, 6)
                OverallProgressBar(session: a.engine.session, tint: color).padding(.bottom, 12)
                ControlButtons(session: a.engine.session, isLandscape: a.isLandscape,
                               onTogglePlay: a.onTogglePlay, onPrevious: a.onPrevious,
                               onNext: a.onNext, onStop: a.onStop)
                    .opacity(a.showControls ? 1 : 0).padding(.bottom, 20)
            }.padding()
        }
    }
}

/// Canvas-drawn vertical hourglass with sand flowing from top to bottom.
private struct HourglassCanvas: View {
    let progress: Double   // 0 = full top, 1 = full bottom
    let sandColor: Color

    var body: some View {
        Canvas { ctx, size in
            let w = size.width; let h = size.height
            let midY = h / 2; let neckW = w * 0.08
            let gi: CGFloat = 4; let capH: CGFloat = 5

            // Glass silhouette path
            let glass = hourglassPath(w: w, h: h, midY: midY, neckW: neckW, gi: gi)

            // Clip sand inside the glass
            ctx.clipToLayer { lc in lc.fill(glass, with: .color(.white)) }

            // Top sand (shrinks)
            let topH = midY * CGFloat(1.0 - progress) * 0.85
            if topH > 1 {
                ctx.fill(Path(CGRect(x: 0, y: midY - topH, width: w, height: topH)),
                         with: .color(sandColor.opacity(0.7)))
            }
            // Falling stream
            if progress > 0.01 && progress < 0.99 {
                let sw: CGFloat = 2.5
                ctx.fill(Path(CGRect(x: w/2 - sw, y: midY - 10, width: sw*2, height: 20)),
                         with: .color(sandColor.opacity(0.9)))
            }
            // Bottom sand (grows)
            let botH = midY * CGFloat(progress) * 0.85
            if botH > 1 {
                ctx.fill(Path(CGRect(x: 0, y: h - botH, width: w, height: botH)),
                         with: .color(sandColor.opacity(0.7)))
            }
            // Glass frame
            ctx.stroke(glass, with: .color(.white.opacity(0.35)), lineWidth: 3)
            // Caps
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: capH)),
                     with: .color(.white.opacity(0.45)))
            ctx.fill(Path(CGRect(x: 0, y: h - capH, width: w, height: capH)),
                     with: .color(.white.opacity(0.45)))
        }
    }

    private func hourglassPath(w: CGFloat, h: CGFloat, midY: CGFloat, neckW: CGFloat, gi: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: gi, y: 0))
        p.addLine(to: CGPoint(x: w - gi, y: 0))
        p.addQuadCurve(to: CGPoint(x: w/2 + neckW, y: midY),
                       control: CGPoint(x: w - gi, y: midY * 0.75))
        p.addQuadCurve(to: CGPoint(x: w - gi, y: h),
                       control: CGPoint(x: w - gi, y: midY + midY * 0.25))
        p.addLine(to: CGPoint(x: gi, y: h))
        p.addQuadCurve(to: CGPoint(x: w/2 - neckW, y: midY),
                       control: CGPoint(x: gi, y: midY + midY * 0.25))
        p.addQuadCurve(to: CGPoint(x: gi, y: 0),
                       control: CGPoint(x: gi, y: midY * 0.75))
        p.closeSubpath()
        return p
    }
}
