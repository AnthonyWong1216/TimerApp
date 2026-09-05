import SwiftUI

struct RoutinePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let configuration: WorkoutConfiguration
    let onStart: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Label(configuration.formattedTotalDuration, systemImage: "clock.fill")
                        Spacer()
                        Text("\(configuration.totalStages) \(NSLocalizedString("home.stages", comment: "stages"))")
                    }
                    .font(.headline)
                }

                ForEach(Array(configuration.usableStageGroups.enumerated()), id: \.element.id) { index, group in
                    Section(groupTitle(group, index: index + 1)) {
                        ForEach(group.stages) { stage in
                            HStack {
                                Circle().fill(stage.colorTheme.color).frame(width: 10, height: 10)
                                Text(stage.name)
                                Spacer()
                                Text(stage.formattedDuration).monospacedDigit()
                            }
                        }
                    }
                }
            }
            .navigationTitle(configuration.name)
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    dismiss()
                    onStart()
                } label: {
                    Label(NSLocalizedString("preview.start", comment: "Start Routine"), systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("editor.cancel", comment: "Cancel")) { dismiss() }
                }
            }
        }
    }

    private func groupTitle(_ group: StageGroup, index: Int) -> String {
        let kind = group.isLoop
            ? String(format: NSLocalizedString("editor.loop_position", comment: ""), index, group.repeatCount)
            : String(format: NSLocalizedString("editor.single_position", comment: ""), index)
        return group.name.isEmpty ? kind : "\(kind) — \(group.name)"
    }
}