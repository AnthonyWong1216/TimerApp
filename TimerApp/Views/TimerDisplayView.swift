//
//  TimerDisplayView.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

/// Full-screen timer display view
/// 全螢幕計時器顯示視圖
struct TimerDisplayView: View {
    @ObservedObject var timerEngine: TimerEngine
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    // MARK: - State
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    @State private var showStopConfirmation = false
    @State private var showingCompletion = false
    @AppStorage("timerNumberFont") private var timerNumberFont = TimerNumberFont.rounded.rawValue
    @AppStorage("timerProgressStyle") private var timerProgressStyle = TimerProgressStyle.circle.rawValue
    
    // MARK: - Computed Properties for Layout
    private var isLandscape: Bool {
        verticalSizeClass == .compact
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background color based on stage type
            backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .opacity(showControls ? 1 : 0)
                
                Spacer()
                
                // Main timer display
                mainTimerView
                
                Spacer()
                
                // Controls
                controlsView
                    .opacity(showControls ? 1 : 0)
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: !showControls)
        .onTapGesture {
            toggleControls()
        }
        .onAppear {
            startControlsTimer()
        }
        .onChange(of: timerEngine.session?.state) { _, state in
            if state == .completed {
                showingCompletion = true
            }
        }
        .onDisappear {
            stopControlsTimer()
        }
        .alert(NSLocalizedString("timer.stop_title", comment: "Stop workout?"), isPresented: $showStopConfirmation) {
            Button(NSLocalizedString("editor.cancel", comment: "Cancel"), role: .cancel) { }
            Button(NSLocalizedString("timer.stop", comment: "Stop"), role: .destructive) {
                timerEngine.stop()
                dismiss()
            }
        } message: {
            Text(NSLocalizedString("timer.stop_message", comment: "Stop workout message"))
        }
        .sheet(isPresented: $showingCompletion, onDismiss: {
            timerEngine.stop()
            dismiss()
        }) {
            WorkoutCompletionView(configuration: timerEngine.session?.configuration) {
                guard let configuration = timerEngine.session?.configuration else { return }
                showingCompletion = false
                timerEngine.startWorkout(configuration: configuration)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundColor: Color {
        guard let stage = timerEngine.session?.currentStage else {
            return Color.black
        }
        return stage.colorTheme.color.opacity(0.3)
    }
    
    private var headerView: some View {
        HStack {
            // Close button
            Button(action: {
                presentStopConfirmation()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.95))
            }
            
            Spacer()
            
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var mainTimerView: some View {
        VStack(spacing: isLandscape ? 16 : 24) {
            // Stage type and name
            if let stage = timerEngine.session?.currentStage {
                VStack(spacing: 8) {
                    if let session = timerEngine.session,
                       let loop = session.configuration.loopDescription(for: session.globalStageIndex) {
                        Label(loop, systemImage: "repeat.circle.fill")
                            .font(.system(size: isLandscape ? 20 : 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(.white.opacity(0.18), in: Capsule())
                    }

                    // Stage type icon
                    Image(systemName: stage.type.iconName)
                        .font(.system(size: isLandscape ? 30 : 40))
                        .foregroundColor(stage.colorTheme.color)
                    
                    // Stage name
                    Text(stage.name)
                        .font(.system(size: isLandscape ? 24 : 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Time remaining with progress circle and play/pause button
            if let session = timerEngine.session {
                VStack(spacing: isLandscape ? 16 : 22) {
                    if progressStyle == .circle {
                        ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 16)
                            .frame(width: circleSize, height: circleSize)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: session.stageProgress)
                            .stroke(
                                session.currentStage?.colorTheme.color ?? .white,
                                style: StrokeStyle(lineWidth: 16, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: session.stageProgress)
                            timerContent(for: session)
                        }
                    } else {
                        timerContent(for: session)
                        ProgressView(value: session.stageProgress)
                            .tint(session.currentStage?.colorTheme.color ?? .white)
                            .frame(width: isLandscape ? 260 : 320)
                            .scaleEffect(x: 1, y: 2.4, anchor: .center)
                    }
                }
            }
            
            // Next stage preview
            if let nextStage = timerEngine.session?.nextStage {
                VStack(spacing: 4) {
                    Text(NSLocalizedString("timer.next", comment: "Next"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.90))
                    
                    HStack(spacing: 8) {
                        Image(systemName: nextStage.type.iconName)
                            .font(.caption)
                        Text(nextStage.name)
                            .font(.subheadline)
                        Text(nextStage.formattedDuration)
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    .foregroundColor(.white.opacity(0.95))
                }
            }
        }
    }
    
    // Circle and font sizes based on orientation
    private var circleSize: CGFloat {
        isLandscape ? 180 : 240
    }
    
    private var timeFont: CGFloat {
        isLandscape ? 80 : 100
    }

    private var progressStyle: TimerProgressStyle {
        TimerProgressStyle(rawValue: timerProgressStyle) ?? .circle
    }

    private var numberFont: TimerNumberFont {
        TimerNumberFont(rawValue: timerNumberFont) ?? .rounded
    }

    private func timerContent(for session: TimerSession) -> some View {
        VStack(spacing: 12) {
            Text(session.formattedTimeRemaining)
                .font(.system(size: timeFont, weight: .bold, design: numberFont.design))
                .foregroundColor(.white)
                .tracking(numberFont == .cyber ? 4 : 0)
                .shadow(color: numberFont == .cyber ? .cyan.opacity(0.85) : .clear, radius: 5)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Button(action: togglePlayPause) {
                Image(systemName: playPauseIcon)
                    .font(.system(size: isLandscape ? 40 : 50))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var controlsView: some View {
        HStack(spacing: isLandscape ? 24 : 18) {
            Button(action: {
                timerEngine.previousStage()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                    Text(NSLocalizedString("timer.previous", comment: "Previous"))
                        .font(.caption)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .foregroundColor(.white.opacity(0.95))
            }
            .disabled((timerEngine.session?.globalStageIndex ?? 0) == 0)

            // Skip button
            Button(action: {
                timerEngine.skipStage()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                    Text(NSLocalizedString("timer.skip", comment: "Skip"))
                        .font(.caption)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .foregroundColor(.white.opacity(0.95))
            }
            
            Spacer()
            
            // Reset button
            Button(action: {
                timerEngine.reset()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                    Text(NSLocalizedString("timer.reset", comment: "Reset"))
                        .font(.caption)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .foregroundColor(.white.opacity(0.95))
            }
        }
        .padding(.horizontal, isLandscape ? 44 : 24)
        .padding(.bottom, 40)
    }
    
    // MARK: - Computed Properties
    
    private var playPauseIcon: String {
        guard let session = timerEngine.session else { return "play.fill" }
        return session.state == .running ? "pause.fill" : "play.fill"
    }
    
    private var playPauseText: String {
        guard let session = timerEngine.session else {
            return NSLocalizedString("timer.start", comment: "Start")
        }
        return session.state == .running ?
            NSLocalizedString("timer.pause", comment: "Pause") :
            NSLocalizedString("timer.resume", comment: "Resume")
    }
    
    // MARK: - Methods
    
    private func togglePlayPause() {
        guard let session = timerEngine.session else { return }
        
        if session.state == .running {
            timerEngine.pause()
        } else if session.state == .paused {
            timerEngine.resume()
        }
    }
    
    private func toggleControls() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showControls.toggle()
        }
        
        if showControls {
            startControlsTimer()
        }
    }
    
    private func startControlsTimer() {
        stopControlsTimer()
        
        controlsTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                showControls = false
            }
        }
    }
    
    private func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
    
    private func presentStopConfirmation() {
        showStopConfirmation = true
    }
}

private struct WorkoutCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let configuration: WorkoutConfiguration?
    let onRepeat: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text(NSLocalizedString("completion.title", comment: "Workout complete"))
                .font(.title.bold())
            if let configuration {
                Text(configuration.name).font(.headline)
                Text("\(configuration.totalStages) \(NSLocalizedString("home.stages", comment: "stages")) • \(configuration.formattedTotalDuration)")
                    .foregroundStyle(.secondary)
            }
            Button {
                dismiss()
                onRepeat()
            } label: {
                Label(NSLocalizedString("completion.repeat", comment: "Repeat Routine"), systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            Button(NSLocalizedString("completion.done", comment: "Done")) { dismiss() }
        }
        .padding(32)
        .presentationDetents([.medium])
    }
}

// MARK: - Preview

#Preview {
    let engine = TimerEngine()
    engine.startWorkout(configuration: .hiit2010)
    
    return TimerDisplayView(timerEngine: engine)
}

// Made with Bob
