//
//  HomeView.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

/// Main home view showing workout configurations
/// 顯示訓練配置的主頁視圖
struct HomeView: View {
    @StateObject private var timerEngine = TimerEngine()
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var configurations: [WorkoutConfiguration] = []
    @State private var showingTimerView = false
    @State private var showingConfigEditor = false
    @State private var showingSettings = false
    @State private var selectedConfiguration: WorkoutConfiguration?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Quick start section
                        if !configurations.isEmpty {
                            quickStartSection
                        }
                        
                        // Configurations list
                        configurationsSection
                        
                        // Sample workouts
                        if configurations.isEmpty {
                            sampleWorkoutsSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("home.title", comment: "Interval Timer"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingConfigEditor) {
                ConfigurationEditorView(
                    configuration: selectedConfiguration,
                    onSave: { config in
                        saveConfiguration(config)
                    }
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showingTimerView) {
                TimerDisplayView(timerEngine: timerEngine)
            }
            .onAppear {
                loadConfigurations()
                requestNotificationPermission()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(NSLocalizedString("home.subtitle", comment: "Custom Interval Timer"))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("home.quick_start", comment: "Quick Start"))
                .font(.headline)
                .foregroundColor(.primary)
            
            if let lastUsed = configurations.first(where: { $0.lastUsed != nil }) {
                WorkoutCard(configuration: lastUsed) {
                    startWorkout(lastUsed)
                }
            }
        }
    }
    
    private var configurationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(NSLocalizedString("home.my_workouts", comment: "My Workouts"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    selectedConfiguration = nil
                    showingConfigEditor = true
                }) {
                    Label(
                        NSLocalizedString("home.create_new", comment: "Create New"),
                        systemImage: "plus.circle.fill"
                    )
                    .font(.subheadline)
                }
            }
            
            if configurations.isEmpty {
                emptyStateView
            } else {
                ForEach(configurations) { config in
                    WorkoutCard(configuration: config) {
                        startWorkout(config)
                    }
                    .contextMenu {
                        Button(action: {
                            selectedConfiguration = config
                            showingConfigEditor = true
                        }) {
                            Label(
                                NSLocalizedString("home.edit", comment: "Edit"),
                                systemImage: "pencil"
                            )
                        }
                        
                        Button(role: .destructive, action: {
                            deleteConfiguration(config)
                        }) {
                            Label(
                                NSLocalizedString("home.delete", comment: "Delete"),
                                systemImage: "trash"
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var sampleWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("home.sample_workouts", comment: "Sample Workouts"))
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(NSLocalizedString("home.sample_subtitle", comment: "Try these pre-configured workouts"))
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(WorkoutConfiguration.samples) { sample in
                WorkoutCard(configuration: sample) {
                    startWorkout(sample)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "timer.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(NSLocalizedString("home.empty_state", comment: "No workouts yet"))
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("home.empty_subtitle", comment: "Create your first workout or try a sample"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Methods
    
    private func startWorkout(_ configuration: WorkoutConfiguration) {
        timerEngine.startWorkout(configuration: configuration)
        showingTimerView = true
    }
    
    private func loadConfigurations() {
        // Load from UserDefaults or CoreData
        if let data = UserDefaults.standard.data(forKey: "savedConfigurations"),
           let decoded = try? JSONDecoder().decode([WorkoutConfiguration].self, from: data) {
            configurations = decoded.sorted { ($0.lastUsed ?? $0.createdAt) > ($1.lastUsed ?? $1.createdAt) }
        }
    }
    
    private func saveConfiguration(_ configuration: WorkoutConfiguration) {
        if let index = configurations.firstIndex(where: { $0.id == configuration.id }) {
            configurations[index] = configuration
        } else {
            configurations.append(configuration)
        }
        
        saveConfigurations()
    }
    
    private func deleteConfiguration(_ configuration: WorkoutConfiguration) {
        configurations.removeAll { $0.id == configuration.id }
        saveConfigurations()
    }
    
    private func saveConfigurations() {
        if let encoded = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(encoded, forKey: "savedConfigurations")
        }
    }
    
    private func requestNotificationPermission() {
        Task {
            await notificationManager.requestAuthorization()
        }
    }
}

// MARK: - Workout Card

struct WorkoutCard: View {
    let configuration: WorkoutConfiguration
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(configuration.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(configuration.stages.count) \(NSLocalizedString("home.stages", comment: "stages")) • \(configuration.rounds) \(NSLocalizedString("home.rounds", comment: "rounds"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(configuration.formattedTotalDuration)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .monospacedDigit()
                        
                        Text(NSLocalizedString("home.total_time", comment: "Total"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Stage preview
                HStack(spacing: 8) {
                    ForEach(configuration.stages.prefix(5)) { stage in
                        Circle()
                            .fill(stage.colorTheme.color)
                            .frame(width: 8, height: 8)
                    }
                    
                    if configuration.stages.count > 5 {
                        Text("+\(configuration.stages.count - 5)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}

// Made with Bob
