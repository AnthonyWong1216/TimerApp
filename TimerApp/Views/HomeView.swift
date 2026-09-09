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
    private enum StorageKey {
        static let savedConfigurations = "savedConfigurations"
        static let hasInitializedWorkouts = "hasInitializedWorkouts"
    }

    @StateObject private var timerEngine = TimerEngine()
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @State private var configurations: [WorkoutConfiguration] = []
    @State private var showingTimerView = false
    @State private var showingNewRoutineEditor = false
    @State private var showingSettings = false
    @State private var selectedConfiguration: WorkoutConfiguration?
    @State private var routineToStart: WorkoutConfiguration?
    @State private var routineToDelete: WorkoutConfiguration?
    
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
            .sheet(item: $selectedConfiguration) { configuration in
                ConfigurationEditorView(
                    configuration: configuration,
                    onSave: { config in
                        saveConfiguration(config)
                    }
                )
            }
            .sheet(isPresented: $showingNewRoutineEditor) {
                ConfigurationEditorView(configuration: nil) { config in
                    saveConfiguration(config)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $routineToStart) { configuration in
                RoutinePreviewView(configuration: configuration) {
                    timerEngine.startWorkout(configuration: configuration)
                    showingTimerView = true
                }
            }
            .fullScreenCover(isPresented: $showingTimerView) {
                TimerDisplayView(timerEngine: timerEngine)
            }
            .onAppear {
                loadConfigurations()
                requestNotificationPermission()
            }
            .alert(
                deleteRoutineTitle,
                isPresented: Binding(
                    get: { routineToDelete != nil },
                    set: { if !$0 { routineToDelete = nil } }
                ),
            ) {
                Button(NSLocalizedString("home.delete", comment: "Delete"), role: .destructive) {
                    if let routineToDelete { deleteConfiguration(routineToDelete) }
                    routineToDelete = nil
                }
                Button(NSLocalizedString("editor.cancel", comment: "Cancel"), role: .cancel) {
                    routineToDelete = nil
                }
            } message: {
                Text(NSLocalizedString("home.delete_routine_message", comment: "Delete routine message"))
            }
        }
    }

    private var deleteRoutineTitle: String {
        guard let routineToDelete else {
            return NSLocalizedString("home.delete_routine_title", comment: "Delete routine")
        }
        return String(
            format: NSLocalizedString("home.delete_routine_named_title", comment: "Delete named routine"),
            routineToDelete.name
        )
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image("TimerLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 84, height: 84)
                .accessibilityLabel("IntervalLoop")
            
            Text(NSLocalizedString("home.subtitle", comment: "Custom Interval Timer"))
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.75))

            Text(NSLocalizedString("home.routine_hint", comment: "Long press a routine to edit or delete it"))
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("home.quick_start", comment: "Quick Start"))
                .font(.headline)
                .foregroundColor(.primary)
            
            if let lastUsed = configurations.first(where: { $0.lastUsed != nil }) {
                WorkoutCard(
                    configuration: lastUsed,
                    onTap: { routineToStart = lastUsed },
                    onMoveUp: {},
                    onMoveDown: {},
                    canMoveUp: false,
                    canMoveDown: false
                )
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
                    showingNewRoutineEditor = true
                }) {
                    Label(
                        NSLocalizedString("home.create_new", comment: "Create New"),
                        systemImage: "plus.circle.fill"
                    )
                    .font(.title3.weight(.semibold))
                }
            }
            
            if configurations.isEmpty {
                emptyStateView
            } else {
                ForEach(configurations) { config in
                    WorkoutCard(
                        configuration: config,
                        onTap: { routineToStart = config },
                        onMoveUp: { moveConfiguration(config, by: -1) },
                        onMoveDown: { moveConfiguration(config, by: 1) },
                        canMoveUp: configurations.first?.id != config.id,
                        canMoveDown: configurations.last?.id != config.id
                    )
                    .contextMenu {
                        Button {
                            selectedConfiguration = config
                        } label: {
                            Label(
                                NSLocalizedString("home.edit", comment: "Edit"),
                                systemImage: "pencil"
                            )
                        }

                        Button(role: .destructive) {
                            routineToDelete = config
                        } label: {
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
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "timer.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(NSLocalizedString("home.empty_state", comment: "No workouts yet"))
                .font(.headline)
                .foregroundStyle(.primary.opacity(0.75))
            
            Text(NSLocalizedString("home.empty_subtitle", comment: "Create your first workout or try a sample"))
                .font(.caption)
                .foregroundStyle(.primary.opacity(0.75))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Methods
    
    private func loadConfigurations() {
        if let data = UserDefaults.standard.data(forKey: StorageKey.savedConfigurations),
           let decoded = try? JSONDecoder().decode([WorkoutConfiguration].self, from: data) {
            configurations = decoded.sorted { ($0.lastUsed ?? $0.createdAt) > ($1.lastUsed ?? $1.createdAt) }
        }

        if !UserDefaults.standard.bool(forKey: StorageKey.hasInitializedWorkouts) {
            configurations.append(contentsOf: WorkoutConfiguration.samples)
            saveConfigurations()
            UserDefaults.standard.set(true, forKey: StorageKey.hasInitializedWorkouts)
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

    private func moveConfiguration(_ configuration: WorkoutConfiguration, by offset: Int) {
        guard let sourceIndex = configurations.firstIndex(where: { $0.id == configuration.id }) else { return }
        let destinationIndex = sourceIndex + offset
        guard configurations.indices.contains(destinationIndex) else { return }

        configurations.swapAt(sourceIndex, destinationIndex)
        saveConfigurations()
    }
    
    private func saveConfigurations() {
        if let encoded = try? JSONEncoder().encode(configurations) {
            UserDefaults.standard.set(encoded, forKey: StorageKey.savedConfigurations)
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
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let canMoveUp: Bool
    let canMoveDown: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(configuration.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(configuration.totalStages) \(NSLocalizedString("home.stages", comment: "stages"))")
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.75))
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
                            .foregroundStyle(.primary.opacity(0.75))
                    }
                }
                
                // Stage preview
                HStack(spacing: 8) {
                    ForEach(configuration.expandedStages.prefix(5)) { stage in
                        Circle()
                            .fill(stage.colorTheme.color)
                            .frame(width: 8, height: 8)
                    }
                    
                    if configuration.totalStages > 5 {
                        Text("+\(configuration.totalStages - 5)")
                            .font(.caption2)
                            .foregroundStyle(.primary.opacity(0.75))
                    }
                }

                HStack(spacing: 14) {
                    if canMoveUp {
                        Button(action: onMoveUp) {
                            Image(systemName: "chevron.up.circle.fill")
                        }
                    }

                    if canMoveDown {
                        Button(action: onMoveDown) {
                            Image(systemName: "chevron.down.circle.fill")
                        }
                    }
                }
                .font(.title3)
                .foregroundStyle(.blue)

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.16), Color.purple.opacity(0.13)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.24), lineWidth: 1)
                }
                .shadow(color: .blue.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}

// Made with Bob
