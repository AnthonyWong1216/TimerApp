import SwiftUI

@main
struct IntervalLoopWatchApp: App {
    @StateObject private var timerStore = WatchTimerStore()

    var body: some Scene {
        WindowGroup {
            WatchTimerView()
                .environmentObject(timerStore)
        }
    }
}
