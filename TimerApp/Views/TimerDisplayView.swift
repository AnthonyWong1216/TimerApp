//
//  TimerDisplayView.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

// MARK: - Main Container

/// Full-screen timer display that delegates rendering to the selected theme.
struct TimerDisplayView: View {
    @ObservedObject var timerEngine: TimerEngine
    @Environment(\.dismiss) private var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var showControls = true
    @State private var controlsTimer: Timer?
    @State private var showStopConfirmation = false
    @State private var showingCompletion = false
    @AppStorage("timerTheme") private var timerTheme = TimerTheme.classic.rawValue

    private var isLandscape: Bool { verticalSizeClass == .compact }
    private var theme: TimerTheme { TimerTheme(rawValue: timerTheme) ?? .classic }

    var body: some View {
        ZStack { themeContent }
        .preferredColorScheme(.dark)
        .statusBar(hidden: !showControls)
        .onAppear { startControlsTimer() }
        .onDisappear { stopControlsTimer() }
        .onChange(of: timerEngine.session?.state) { _, state in
            if state == .completed { showingCompletion = true }
        }
        .alert(NSLocalizedString("timer.stop_title", comment: ""), isPresented: $showStopConfirmation) {
            Button(NSLocalizedString("editor.cancel", comment: ""), role: .cancel) { }
            Button(NSLocalizedString("timer.stop", comment: ""), role: .destructive) {
                timerEngine.stop(); dismiss()
            }
        } message: { Text(NSLocalizedString("timer.stop_message", comment: "")) }
        .sheet(isPresented: $showingCompletion, onDismiss: { timerEngine.stop(); dismiss() }) {
            WorkoutCompletionView(configuration: timerEngine.session?.configuration) {
                guard let c = timerEngine.session?.configuration else { return }
                showingCompletion = false
                timerEngine.startWorkout(configuration: c)
            }
        }
    }

    @ViewBuilder private var themeContent: some View {
        let args = ThemeArgs(engine: timerEngine, showControls: showControls, isLandscape: isLandscape,
                             onTogglePlay: togglePlayPause, onPrevious: { timerEngine.previousStage() },
                             onNext: { timerEngine.skipStage() }, onStop: { showStopConfirmation = true },
                             onToggleControls: toggleControls)
        switch theme {
        case .classic:    ThemeClassic(a: args)
        case .fullscreen: ThemeFullScreen(a: args)
        case .timeline:   ThemeTimeline(a: args)
        case .cyberpunk:  ThemeCyberpunk(a: args)
        case .hourglass:  ThemeHourglass(a: args)
        }
    }

    private func togglePlayPause() {
        guard let s = timerEngine.session else { return }
        if s.state == .running { timerEngine.pause() } else if s.state == .paused { timerEngine.resume() }
    }
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) { showControls.toggle() }
        if showControls { startControlsTimer() }
    }
    private func startControlsTimer() {
        stopControlsTimer()
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) { showControls = false }
        }
    }
    private func stopControlsTimer() { controlsTimer?.invalidate(); controlsTimer = nil }
}

// MARK: - Preview

#Preview {
    let engine = TimerEngine()
    engine.startWorkout(configuration: .hiit2010)
    return TimerDisplayView(timerEngine: engine)
}

// Made with Bob
