//
//  ConfigurationEditorView.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

/// View for creating and editing workout configurations
/// 創建和編輯訓練配置的視圖
struct ConfigurationEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    let configuration: WorkoutConfiguration?
    let onSave: (WorkoutConfiguration) -> Void
    
    @State private var name: String = ""
    @State private var rounds: Int = 1
    @State private var skipLastRest: Bool = false
    @State private var stages: [TimerStage] = []
    @State private var showingStageEditor = false
    @State private var editingStage: TimerStage?
    @State private var editingStageIndex: Int?
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic info section
                Section {
                    TextField(
                        NSLocalizedString("editor.name", comment: "Workout Name"),
                        text: $name
                    )
                    
                    Stepper(
                        "\(NSLocalizedString("editor.rounds", comment: "Rounds")): \(rounds)",
                        value: $rounds,
                        in: 1...99
                    )
                    
                    Toggle(
                        NSLocalizedString("editor.skip_last_rest", comment: "Skip Last Rest"),
                        isOn: $skipLastRest
                    )
                } header: {
                    Text(NSLocalizedString("editor.basic_info", comment: "Basic Information"))
                }
                
                // Stages section
                Section {
                    ForEach(Array(stages.enumerated()), id: \.element.id) { index, stage in
                        StageRow(stage: stage, index: index + 1)
                            .onTapGesture {
                                editStage(stage, at: index)
                            }
                    }
                    .onDelete(perform: deleteStages)
                    .onMove(perform: moveStages)
                    
                    Button(action: {
                        editingStage = nil
                        editingStageIndex = nil
                        showingStageEditor = true
                    }) {
                        Label(
                            NSLocalizedString("editor.add_stage", comment: "Add Stage"),
                            systemImage: "plus.circle.fill"
                        )
                    }
                } header: {
                    Text(NSLocalizedString("editor.stages", comment: "Stages"))
                } footer: {
                    if !stages.isEmpty {
                        Text(totalDurationText)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle(configuration == nil ?
                NSLocalizedString("editor.new_workout", comment: "New Workout") :
                NSLocalizedString("editor.edit_workout", comment: "Edit Workout")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("editor.cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("editor.save", comment: "Save")) {
                        saveConfiguration()
                    }
                    .disabled(!isValid)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingStageEditor) {
                StageEditorView(
                    stage: editingStage,
                    onSave: { stage in
                        if let index = editingStageIndex {
                            stages[index] = stage
                        } else {
                            stages.append(stage)
                        }
                    }
                )
            }
            .onAppear {
                loadConfiguration()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !stages.isEmpty
    }
    
    private var totalDurationText: String {
        let config = WorkoutConfiguration(
            name: name,
            stages: stages,
            rounds: rounds,
            skipLastRest: skipLastRest
        )
        return "\(NSLocalizedString("editor.total_duration", comment: "Total Duration")): \(config.formattedTotalDuration)"
    }
    
    // MARK: - Methods
    
    private func loadConfiguration() {
        if let config = configuration {
            name = config.name
            rounds = config.rounds
            skipLastRest = config.skipLastRest
            stages = config.stages
        }
    }
    
    private func saveConfiguration() {
        let config = WorkoutConfiguration(
            id: configuration?.id ?? UUID(),
            name: name,
            stages: stages,
            rounds: rounds,
            skipLastRest: skipLastRest,
            createdAt: configuration?.createdAt ?? Date(),
            lastUsed: configuration?.lastUsed
        )
        
        onSave(config)
        dismiss()
    }
    
    private func editStage(_ stage: TimerStage, at index: Int) {
        editingStage = stage
        editingStageIndex = index
        showingStageEditor = true
    }
    
    private func deleteStages(at offsets: IndexSet) {
        stages.remove(atOffsets: offsets)
    }
    
    private func moveStages(from source: IndexSet, to destination: Int) {
        stages.move(fromOffsets: source, toOffset: destination)
    }
}

// MARK: - Stage Row

struct StageRow: View {
    let stage: TimerStage
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Stage number
            Text("\(index)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            // Color indicator
            Circle()
                .fill(stage.colorTheme.color)
                .frame(width: 12, height: 12)
            
            // Stage info
            VStack(alignment: .leading, spacing: 2) {
                Text(stage.name)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(stage.type.localizedName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Duration
            Text(stage.formattedDuration)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Stage Editor View

struct StageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    let stage: TimerStage?
    let onSave: (TimerStage) -> Void
    
    @State private var name: String = ""
    @State private var duration: TimeInterval = 30
    @State private var type: StageType = .workout
    @State private var colorTheme: StageColor = .red
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        NSLocalizedString("stage.name", comment: "Stage Name"),
                        text: $name
                    )
                    
                    Picker(
                        NSLocalizedString("stage.type", comment: "Type"),
                        selection: $type
                    ) {
                        ForEach(StageType.allCases, id: \.self) { type in
                            Label(type.localizedName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    
                    Picker(
                        NSLocalizedString("stage.color", comment: "Color"),
                        selection: $colorTheme
                    ) {
                        ForEach(StageColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 20, height: 20)
                                Text(color.localizedName)
                            }
                            .tag(color)
                        }
                    }
                }
                
                Section {
                    DurationPicker(duration: $duration)
                } header: {
                    Text(NSLocalizedString("stage.duration", comment: "Duration"))
                }
                
                Section {
                    // Preview
                    VStack(spacing: 16) {
                        Circle()
                            .fill(colorTheme.color)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: type.iconName)
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            )
                        
                        Text(name.isEmpty ? type.localizedName : name)
                            .font(.headline)
                        
                        Text(formatDuration(duration))
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                } header: {
                    Text(NSLocalizedString("stage.preview", comment: "Preview"))
                }
            }
            .navigationTitle(stage == nil ?
                NSLocalizedString("stage.new", comment: "New Stage") :
                NSLocalizedString("stage.edit", comment: "Edit Stage")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("stage.cancel", comment: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("stage.save", comment: "Save")) {
                        saveStage()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                loadStage()
            }
        }
    }
    
    private func loadStage() {
        if let stage = stage {
            name = stage.name
            duration = stage.duration
            type = stage.type
            colorTheme = stage.colorTheme
        } else {
            name = type.localizedName
            colorTheme = type.defaultColor
        }
    }
    
    private func saveStage() {
        let newStage = TimerStage(
            id: stage?.id ?? UUID(),
            name: name,
            duration: duration,
            type: type,
            colorTheme: colorTheme
        )
        
        onSave(newStage)
        dismiss()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Duration Picker

struct DurationPicker: View {
    @Binding var duration: TimeInterval
    
    private var minutes: Int {
        Int(duration) / 60
    }
    
    private var seconds: Int {
        Int(duration) % 60
    }
    
    var body: some View {
        HStack {
            Picker("Minutes", selection: Binding(
                get: { minutes },
                set: { duration = TimeInterval($0 * 60 + seconds) }
            )) {
                ForEach(0..<60) { minute in
                    Text("\(minute)").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            
            Text(NSLocalizedString("duration.minutes", comment: "min"))
                .foregroundColor(.secondary)
            
            Picker("Seconds", selection: Binding(
                get: { seconds },
                set: { duration = TimeInterval(minutes * 60 + $0) }
            )) {
                ForEach(0..<60) { second in
                    Text("\(second)").tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            
            Text(NSLocalizedString("duration.seconds", comment: "sec"))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    ConfigurationEditorView(configuration: nil) { _ in }
}

// Made with Bob
