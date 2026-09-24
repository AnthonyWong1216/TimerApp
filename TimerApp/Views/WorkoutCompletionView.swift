//
//  WorkoutCompletionView.swift
//  IntervalTimer
//
//  Shown as a sheet when the workout finishes.
//

import SwiftUI

struct WorkoutCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    let configuration: WorkoutConfiguration?
    let onRepeat: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 72)).foregroundStyle(.green)
            Text(NSLocalizedString("completion.title", comment: "")).font(.title.bold())
            if let c = configuration {
                Text(c.name).font(.headline)
                Text("\(c.totalStages) \(NSLocalizedString("home.stages", comment: "")) • \(c.formattedTotalDuration)")
                    .foregroundStyle(.secondary)
            }
            Button { dismiss(); onRepeat() } label: {
                Label(NSLocalizedString("completion.repeat", comment: ""), systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }.buttonStyle(.borderedProminent)
            Button(NSLocalizedString("completion.done", comment: "")) { dismiss() }
        }.padding(32).presentationDetents([.medium])
    }
}
