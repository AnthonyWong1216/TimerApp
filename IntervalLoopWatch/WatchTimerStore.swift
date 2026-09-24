import Foundation
import Combine
import WatchConnectivity

struct WatchTimerSnapshot: Equatable {
    var isConnected = false
    var isRunning = false
    var routineName = "IntervalLoop"
    var stageName = ""
    var stageType = ""
    var timeRemaining = 0
    var stageIndex = 0
    var totalStages = 0
    var loopDescription = ""

    var formattedTime: String {
        String(format: "%02d:%02d", max(0, timeRemaining) / 60, max(0, timeRemaining) % 60)
    }
}

final class WatchTimerStore: NSObject, ObservableObject {
    @Published private(set) var snapshot = WatchTimerSnapshot()

    private var session: WCSession?

    override init() {
        super.init()

        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
    }

    func send(_ command: String) {
        guard let session else { return }
        let message = ["command": command]

        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { _ in
                session.transferUserInfo(message)
            }
        } else {
            session.transferUserInfo(message)
        }
    }

    private func apply(_ values: [String: Any]) {
        DispatchQueue.main.async {
            self.snapshot = WatchTimerSnapshot(
                isConnected: true,
                isRunning: values["isRunning"] as? Bool ?? false,
                routineName: values["routineName"] as? String ?? "IntervalLoop",
                stageName: values["stageName"] as? String ?? "",
                stageType: values["stageType"] as? String ?? "",
                timeRemaining: values["timeRemaining"] as? Int ?? 0,
                stageIndex: values["stageIndex"] as? Int ?? 0,
                totalStages: values["totalStages"] as? Int ?? 0,
                loopDescription: values["loopDescription"] as? String ?? ""
            )
        }
    }
}

extension WatchTimerStore: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            #if DEBUG
            print("[Watch] WCSession activation failed: \(error.localizedDescription)")
            #endif
            return
        }
        guard activationState == .activated else {
            #if DEBUG
            print("[Watch] WCSession not activated, state: \(activationState.rawValue)")
            #endif
            return
        }
        #if DEBUG
        print("[Watch] WCSession activated. receivedApplicationContext keys: \(session.receivedApplicationContext.keys.sorted())")
        #endif
        if !session.receivedApplicationContext.isEmpty {
            apply(session.receivedApplicationContext)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        #if DEBUG
        print("[Watch] didReceiveApplicationContext: \(applicationContext)")
        #endif
        apply(applicationContext)
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        #if DEBUG
        print("[Watch] didReceiveUserInfo: \(userInfo)")
        #endif
        apply(userInfo)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        #if DEBUG
        print("[Watch] didReceiveMessage (with reply): \(message)")
        #endif
        apply(message)
        replyHandler([:])
    }
}