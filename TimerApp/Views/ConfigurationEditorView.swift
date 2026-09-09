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
    @State private var stageGroups: [StageGroup] = []
    @State private var showingStageEditor = false
    @State private var editingStage: TimerStage?
    @State private var editingGroupID: UUID?
    @State private var insertBeforeStageID: UUID?
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic info section
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("editor.routine_name", comment: "Routine Name"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.75))
                        TextField(
                            NSLocalizedString("editor.routine_name_placeholder", comment: "Routine Name"),
                            text: $name
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
                    }
                    
                } header: {
                    Text(NSLocalizedString("editor.basic_info", comment: "Basic Information"))
                }
                
                // Stages section
                Section {
                    ForEach(Array(stageGroups.enumerated()), id: \.element.id) { index, group in
                        StageGroupBlock(
                            group: group,
                            position: index + 1,
                            onRepeatCountChange: { updateRepeatCount($0, for: group.id) },
                            onNameChange: { updateGroupName($0, for: group.id) },
                            onMoveGroupUp: { moveGroup(group.id, by: -1) },
                            onMoveGroupDown: { moveGroup(group.id, by: 1) },
                            canMoveGroupUp: index > 0,
                            canMoveGroupDown: index < stageGroups.count - 1,
                            onEditStage: { editStage($0, in: group.id) },
                            onInsertBeforeStage: { insertStage(before: $0, in: group.id) },
                            onDeleteStage: { deleteStage($0, from: group.id) },
                            onMoveStageUp: { moveStage($0, in: group.id, by: -1) },
                            onMoveStageDown: { moveStage($0, in: group.id, by: 1) },
                            onAddStage: { addStage(to: group.id) },
                            onDeleteGroup: { deleteGroup(group.id) }
                        )
                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                    Button { addGroup(repeatCount: 1) } label: {
                        Label(NSLocalizedString("editor.add_single", comment: "Add Single Run"), systemImage: "plus")
                    }
                    Button { addGroup(repeatCount: 2) } label: {
                        Label(NSLocalizedString("editor.add_loop", comment: "Add Loop Run"), systemImage: "repeat")
                    }
                } header: {
                    Text(NSLocalizedString("editor.stages", comment: "Stages"))
                } footer: {
                    if !stageGroups.isEmpty {
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
                
            }
            .sheet(isPresented: $showingStageEditor) {
                StageEditorView(
                    stage: editingStage,
                    onSave: { stage in
                        saveStage(stage)
                    }
                )
            }
            .task(id: configuration?.id) {
                loadConfiguration()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && stageGroups.contains { !$0.stages.isEmpty }
    }
    
    private var totalDurationText: String {
        let config = WorkoutConfiguration(
            name: name,
            stageGroups: stageGroups
        )
        return "\(NSLocalizedString("editor.total_duration", comment: "Total Duration")): \(config.formattedTotalDuration)"
    }
    
    // MARK: - Methods
    
    private func loadConfiguration() {
        if let config = configuration {
            name = config.name
            stageGroups = config.usableStageGroups
        } else {
            name = ""
            stageGroups = []
        }
    }
    
    private func saveConfiguration() {
        let config = WorkoutConfiguration(
            id: configuration?.id ?? UUID(),
            name: name,
            stages: stageGroups.flatMap(\.stages),
            stageGroups: stageGroups,
            createdAt: configuration?.createdAt ?? Date(),
            lastUsed: configuration?.lastUsed
        )
        
        onSave(config)
        dismiss()
    }
    
    private func editStage(_ stage: TimerStage, in groupID: UUID) {
        editingStage = stage
        editingGroupID = groupID
        insertBeforeStageID = nil
        showingStageEditor = true
    }
    
    private func addGroup(repeatCount: Int) {
        let group = StageGroup(repeatCount: repeatCount)
        stageGroups.append(group)
        addStage(to: group.id)
    }

    private func updateRepeatCount(_ repeatCount: Int, for groupID: UUID) {
        guard let index = stageGroups.firstIndex(where: { $0.id == groupID }) else { return }
        stageGroups[index].repeatCount = repeatCount
    }

    private func updateGroupName(_ name: String, for groupID: UUID) {
        guard let index = stageGroups.firstIndex(where: { $0.id == groupID }) else { return }
        stageGroups[index].name = name
    }

    private func moveGroup(_ groupID: UUID, by offset: Int) {
        guard let sourceIndex = stageGroups.firstIndex(where: { $0.id == groupID }) else { return }
        let destinationIndex = sourceIndex + offset
        guard stageGroups.indices.contains(destinationIndex) else { return }
        stageGroups.swapAt(sourceIndex, destinationIndex)
    }

    private func addStage(to groupID: UUID) {
        editingStage = nil
        editingGroupID = groupID
        insertBeforeStageID = nil
        showingStageEditor = true
    }

    private func insertStage(before stage: TimerStage, in groupID: UUID) {
        editingStage = nil
        editingGroupID = groupID
        insertBeforeStageID = stage.id
        showingStageEditor = true
    }

    private func saveStage(_ stage: TimerStage) {
        guard let groupIndex = stageGroups.firstIndex(where: { $0.id == editingGroupID }) else { return }
        if let stageIndex = stageGroups[groupIndex].stages.firstIndex(where: { $0.id == stage.id }) {
            stageGroups[groupIndex].stages[stageIndex] = stage
        } else if let insertBeforeStageID,
                  let insertIndex = stageGroups[groupIndex].stages.firstIndex(where: { $0.id == insertBeforeStageID }) {
            stageGroups[groupIndex].stages.insert(stage, at: insertIndex)
        } else {
            stageGroups[groupIndex].stages.append(stage)
        }
        self.insertBeforeStageID = nil
    }

    private func deleteStage(_ stage: TimerStage, from groupID: UUID) {
        guard let groupIndex = stageGroups.firstIndex(where: { $0.id == groupID }) else { return }
        stageGroups[groupIndex].stages.removeAll { $0.id == stage.id }
    }

    private func moveStage(_ stage: TimerStage, in groupID: UUID, by offset: Int) {
        guard let groupIndex = stageGroups.firstIndex(where: { $0.id == groupID }),
              let sourceIndex = stageGroups[groupIndex].stages.firstIndex(where: { $0.id == stage.id }) else { return }
        let destinationIndex = sourceIndex + offset
        guard stageGroups[groupIndex].stages.indices.contains(destinationIndex) else { return }
        stageGroups[groupIndex].stages.swapAt(sourceIndex, destinationIndex)
    }

    private func deleteGroup(_ groupID: UUID) {
        stageGroups.removeAll { $0.id == groupID }
    }
}

// MARK: - Stage Group Block

private struct StageGroupBlock: View {
    let group: StageGroup
    let position: Int
    let onRepeatCountChange: (Int) -> Void
    let onNameChange: (String) -> Void
    let onMoveGroupUp: () -> Void
    let onMoveGroupDown: () -> Void
    let canMoveGroupUp: Bool
    let canMoveGroupDown: Bool
    let onEditStage: (TimerStage) -> Void
    let onInsertBeforeStage: (TimerStage) -> Void
    let onDeleteStage: (TimerStage) -> Void
    let onMoveStageUp: (TimerStage) -> Void
    let onMoveStageDown: (TimerStage) -> Void
    let onAddStage: () -> Void
    let onDeleteGroup: () -> Void

    private var isLoop: Bool { group.repeatCount > 1 }
    private var accentColor: Color { isLoop ? .purple : .blue }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: isLoop ? "repeat" : "play.fill")
                    .font(.subheadline.weight(.semibold))
                Text(headerTitle)
                    .font(.headline)
                Spacer()
                ReorderButtons(
                    onMoveUp: onMoveGroupUp,
                    onMoveDown: onMoveGroupDown,
                    canMoveUp: canMoveGroupUp,
                    canMoveDown: canMoveGroupDown
                )
                if isLoop {
                    Stepper("", value: Binding(
                        get: { group.repeatCount },
                        set: onRepeatCountChange
                    ), in: 2...99)
                    .labelsHidden()
                }
                Button(action: onDeleteGroup) {
                    Image(systemName: "minus")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(.red))
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(NSLocalizedString("editor.delete_group", comment: "Delete group"))
            }
            .foregroundStyle(accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(accentColor.opacity(0.14))

            VStack(alignment: .leading, spacing: 6) {
                Text(NSLocalizedString("editor.group_name_label", comment: "Name"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(accentColor)

                TextField(
                    NSLocalizedString("editor.group_name_placeholder", comment: "Workout name"),
                    text: Binding(get: { group.name }, set: onNameChange)
                )
                .font(.subheadline)
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.tertiarySystemBackground))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.30), lineWidth: 1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(accentColor.opacity(0.07))

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(group.stages.enumerated()), id: \.element.id) { index, stage in
                    StageRow(
                        stage: stage,
                        loopCount: group.repeatCount,
                        onEdit: { onEditStage(stage) },
                        onInsertBefore: { onInsertBeforeStage(stage) },
                        onDelete: { onDeleteStage(stage) },
                        onMoveUp: { onMoveStageUp(stage) },
                        onMoveDown: { onMoveStageDown(stage) },
                        canMoveUp: index > 0,
                        canMoveDown: index < group.stages.count - 1
                    )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                }
                if group.stages.isEmpty {
                    Text(NSLocalizedString("editor.empty_group", comment: "No stages in this group"))
                        .font(.caption)
                            .foregroundStyle(.primary.opacity(0.75))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }

                Button(action: onAddStage) {
                    Label(NSLocalizedString("editor.add_stage", comment: "Add Stage"), systemImage: "plus.circle.fill")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

            }
            .padding(.leading, 18)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(accentColor.opacity(0.75))
                    .frame(width: 3)
                    .padding(.vertical, 8)
            }

            HStack(spacing: 7) {
                Image(systemName: isLoop ? "arrow.uturn.down" : "checkmark")
                    .font(.caption.weight(.semibold))
                Text(isLoop
                    ? String(format: NSLocalizedString("editor.end_loop", comment: "End of Loop %d"), position)
                    : NSLocalizedString("editor.end_single", comment: "End Single Run"))
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(accentColor.opacity(0.10))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor.opacity(0.55), lineWidth: 1)
        }
    }

    private var headerTitle: String {
        let title = isLoop
            ? String(format: NSLocalizedString("editor.loop_position", comment: "Loop %d — run %d times"), position, group.repeatCount)
            : String(format: NSLocalizedString("editor.single_position", comment: "Single Run %d"), position)
        return group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? title : "\(title) — \(group.name)"
    }
}

// MARK: - Stage Row

struct StageRow: View {
    let stage: TimerStage
    let loopCount: Int
    let onEdit: () -> Void
    let onInsertBefore: () -> Void
    let onDelete: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let canMoveUp: Bool
    let canMoveDown: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onInsertBefore) {
                Image(systemName: "plus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(.blue))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(NSLocalizedString("editor.insert_stage", comment: "Insert Stage"))

            ReorderButtons(
                onMoveUp: onMoveUp,
                onMoveDown: onMoveDown,
                canMoveUp: canMoveUp,
                canMoveDown: canMoveDown
            )

            Button(action: onEdit) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(stage.colorTheme.color)
                        .frame(width: 12, height: 12)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(stage.name)
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("\(stage.type.localizedName) • \(loopCount == 1 ? NSLocalizedString("editor.single_run", comment: "Single Run") : String(format: NSLocalizedString("editor.loop_run", comment: "Loop Run %d times"), loopCount))")
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.75))
                    }

                    Spacer()

                    Text(stage.formattedDuration)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
                .contentShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "minus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(.red))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(NSLocalizedString("home.delete", comment: "Delete"))
        }
        .padding(.vertical, 5)
    }
}

private struct ReorderButtons: View {
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let canMoveUp: Bool
    let canMoveDown: Bool

    var body: some View {
        HStack(spacing: 2) {
            Button(action: onMoveUp) {
                Image(systemName: "chevron.up.circle.fill")
            }
            .disabled(!canMoveUp)

            Button(action: onMoveDown) {
                Image(systemName: "chevron.down.circle.fill")
            }
            .disabled(!canMoveDown)
        }
        .font(.subheadline)
        .foregroundStyle(.blue)
        .buttonStyle(.borderless)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Stage Editor View

struct StageEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    let stage: TimerStage?
    let onSave: (TimerStage) -> Void
    
    @State private var name: String = ""
    @State private var duration: TimeInterval = 0
    @State private var type: StageType = .workout
    @State private var colorTheme: StageColor = .red
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Stage type picker with icons and colors
                    // 帶圖示和顏色的階段類型選擇器
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("stage.type", comment: "Type"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.75))
                        
                        HStack(spacing: 10) {
                            ForEach(StageType.allCases, id: \.self) { stageType in
                                Button {
                                    type = stageType
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: stageType.iconName)
                                            .font(.subheadline.weight(.semibold))
                                        Text(stageType.localizedName)
                                            .font(.subheadline.weight(.semibold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .foregroundStyle(type == stageType ? .white : stageType.defaultColor.color)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(type == stageType ? stageType.defaultColor.color : stageType.defaultColor.color.opacity(0.15))
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(type == stageType ? .isSelected : [])
                            }
                        }
                    }
                    .onChange(of: type) { _, newType in
                        // Set a useful title and conventional color when changing type.
                        name = newType.localizedName
                        colorTheme = newType.defaultColor
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(NSLocalizedString("stage.name", comment: "Stage Name"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.75))
                        TextField(
                            NSLocalizedString("stage.name_placeholder", comment: "Stage title"),
                            text: $name
                        )
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
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
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("duration.quick_select", comment: "Quick select duration"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.8))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(DurationPreset.allCases) { preset in
                                    Button {
                                        duration = preset.duration
                                    } label: {
                                        Text(preset.localizedTitle)
                                            .font(.subheadline.weight(.semibold))
                                            .monospacedDigit()
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 9)
                                            .foregroundStyle(duration == preset.duration ? .white : .primary)
                                            .background(
                                                Capsule()
                                                    .fill(duration == preset.duration ? Color.accentColor : Color(.tertiarySystemBackground))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel(preset.localizedTitle)
                                    .accessibilityAddTraits(duration == preset.duration ? .isSelected : [])
                                }
                            }
                        }

                        Text(NSLocalizedString("duration.custom", comment: "Custom Duration"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary.opacity(0.8))

                        DurationPicker(duration: $duration)
                    }
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
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || duration <= 0)
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

private enum DurationPreset: CaseIterable, Identifiable {
    case seconds30
    case minute1
    case minute2
    case minute3
    case minute4
    case minute5

    var id: Self { self }

    var duration: TimeInterval {
        switch self {
        case .seconds30: 30
        case .minute1: 60
        case .minute2: 120
        case .minute3: 180
        case .minute4: 240
        case .minute5: 300
        }
    }

    var localizedTitle: String {
        switch self {
        case .seconds30:
            NSLocalizedString("duration.preset.30_seconds", comment: "30 seconds preset")
        case .minute1:
            NSLocalizedString("duration.preset.1_minute", comment: "1 minute preset")
        case .minute2:
            NSLocalizedString("duration.preset.2_minutes", comment: "2 minutes preset")
        case .minute3:
            NSLocalizedString("duration.preset.3_minutes", comment: "3 minutes preset")
        case .minute4:
            NSLocalizedString("duration.preset.4_minutes", comment: "4 minutes preset")
        case .minute5:
            NSLocalizedString("duration.preset.5_minutes", comment: "5 minutes preset")
        }
    }
}

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
                .foregroundStyle(.primary.opacity(0.75))
            
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
                .foregroundStyle(.primary.opacity(0.75))
        }
    }
}

// MARK: - Preview

#Preview {
    ConfigurationEditorView(configuration: nil) { _ in }
}

// Made with Bob
