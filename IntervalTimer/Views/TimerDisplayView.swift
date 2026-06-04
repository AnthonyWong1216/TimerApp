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
    
    // MARK: - State
    @State private var showControls = true
    @State private var controlsTimer: Timer?
    
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
        .onDisappear {
            stopControlsTimer()
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
                showStopConfirmation()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            // Round counter
            if let session = timerEngine.session {
                Text("\(session.currentRound) / \(session.configuration.rounds)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var mainTimerView: some View {
        VStack(spacing: 24) {
            // Stage type and name
            if let stage = timerEngine.session?.currentStage {
                VStack(spacing: 8) {
                    // Stage type icon
                    Image(systemName: stage.type.iconName)
                        .font(.system(size: 40))
                        .foregroundColor(stage.colorTheme.color)
                    
                    // Stage name
                    Text(stage.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Time remaining - Large display
            if let session = timerEngine.session {
                Text(session.formattedTimeRemaining)
                    .font(.system(size: 120, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            
            // Progress circle
            if let session = timerEngine.session {
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 200, height: 200)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: session.stageProgress)
                        .stroke(
                            session.currentStage?.colorTheme.color ?? .white,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: session.stageProgress)
                }
            }
            
            // Next stage preview
            if let nextStage = timerEngine.session?.nextStage {
                VStack(spacing: 4) {
                    Text(NSLocalizedString("timer.next", comment: "Next"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 8) {
                        Image(systemName: nextStage.type.iconName)
                            .font(.caption)
                        Text(nextStage.name)
                            .font(.subheadline)
                        Text(nextStage.formattedDuration)
                            .font(.subheadline)
                            .monospacedDigit()
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
        }
    }
    
    private var controlsView: some View {
        HStack(spacing: 40) {
            // Skip button
            Button(action: {
                timerEngine.skipStage()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                    Text(NSLocalizedString("timer.skip", comment: "Skip"))
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.8))
            }
            
            // Play/Pause button
            Button(action: {
                togglePlayPause()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: playPauseIcon)
                        .font(.system(size: 60))
                    Text(playPauseText)
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            
            // Reset button
            Button(action: {
                timerEngine.reset()
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title)
                    Text(NSLocalizedString("timer.reset", comment: "Reset"))
                        .font(.caption)
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
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
    
    private func showStopConfirmation() {
        // This would show an alert in a real implementation
        timerEngine.stop()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    let engine = TimerEngine()
    engine.startWorkout(configuration: .hiit2010)
    
    return TimerDisplayView(timerEngine: engine)
}

// Made with Bob
