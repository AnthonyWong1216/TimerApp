//
//  ThemeCyberpunk.swift
//  IntervalTimer
//
//  Theme D: Cyberpunk neon with scanlines and glow.
//

import SwiftUI

struct ThemeCyberpunk: View {
    let a: ThemeArgs
    @State private var glowPulse = false
    @AppStorage("timerNumberFont") private var fontKey = TimerNumberFont.rounded.rawValue
    private var font: TimerNumberFont { TimerNumberFont(rawValue: fontKey) ?? .rounded }

    private let nCyan    = Color(red: 0, green: 1, blue: 1)
    private let nMagenta = Color(red: 1, green: 0, blue: 0.8)
    private let nYellow  = Color(red: 1, green: 1, blue: 0)

    private var accent: Color {
        guard let s = a.engine.session?.currentStage else { return nCyan }
        switch s.type { case .workout: return nMagenta; case .rest: return nCyan; case .prepare: return nYellow }
    }

    var body: some View {
        let t = a.engine.session?.formattedTimeRemaining ?? "00:00"
        let p = a.engine.session?.stageProgress ?? 0
        let rem = a.engine.session?.timeRemaining ?? 99

        ZStack {
            // Background + tap to toggle controls
            Color(red: 0.04, green: 0.02, blue: 0.08).ignoresSafeArea()
                .onTapGesture { a.onToggleControls() }

            // Scanlines overlay (decorative, non-interactive)
            scanlines.ignoresSafeArea().allowsHitTesting(false)

            // Main content
            VStack(spacing: 0) {
                ThemeHeader(engine: a.engine, onStop: a.onStop, tint: accent)
                    .opacity(a.showControls ? 1 : 0)

                Spacer()

                if let s = a.engine.session?.currentStage {
                    Text(s.type.localizedName.uppercased())
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .tracking(8).foregroundStyle(accent).shadow(color: accent, radius: 8)
                        .padding(.bottom, 4)
                }
                timerDigitsView(text: t, font: font, size: a.isLandscape ? 70 : 90, color: accent, weight: .black)
                    .shadow(color: accent, radius: glowPulse ? 24 : 12)
                    .shadow(color: accent.opacity(0.5), radius: glowPulse ? 48 : 24)
                    .scaleEffect(rem <= 5 ? 1.06 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: rem <= 5)

                ProgressView(value: p)
                    .progressViewStyle(.linear)
                    .tint(accent)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)

                Spacer()

                NextLabel(session: a.engine.session, fg: accent.opacity(0.7))
                    .padding(.bottom, 6)
                OverallProgressBar(session: a.engine.session, tint: accent).padding(.bottom, 12)
                cpControls
                    .opacity(a.showControls ? 1 : 0)
                    .padding(.bottom, 20)
            }.padding()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { glowPulse = true }
        }
    }

    /// Horizontal scanline effect — fixed-height rows, no Spacer.
    private var scanlines: some View {
        Canvas { context, size in
            for y in stride(from: 0, to: size.height, by: 4) {
                context.fill(
                    Path(CGRect(x: 0, y: y, width: size.width, height: 1)),
                    with: .color(.white.opacity(0.015))
                )
            }
        }
    }

    private var cpControls: some View {
        HStack(spacing: a.isLandscape ? 40 : 28) {
            cpBtn("backward.fill", action: a.onPrevious)
            cpBtn(a.engine.session?.state == .running ? "pause.fill" : "play.fill",
                  action: a.onTogglePlay, large: true)
            cpBtn("forward.fill", action: a.onNext)
            cpBtn("stop.fill", action: a.onStop)
        }
    }

    private func cpBtn(_ icon: String, action: @escaping () -> Void, large: Bool = false) -> some View {
        Button(action: action) {
            Image(systemName: icon).font(large ? .system(size: 32) : .title2)
                .foregroundStyle(accent)
                .shadow(color: accent, radius: 6)
                .frame(width: large ? 72 : 52, height: large ? 72 : 52)
                .background(
                    RoundedRectangle(cornerRadius: large ? 36 : 10)
                        .fill(accent.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: large ? 36 : 10)
                                .stroke(accent.opacity(0.6), lineWidth: 1.5)
                        )
                        .shadow(color: accent.opacity(0.4), radius: 8)
                )
                .contentShape(Rectangle())
        }
    }
}
