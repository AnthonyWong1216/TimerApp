import Foundation
import WatchConnectivity

/// Synchronizes the iPhone-owned timer with its paired Apple Watch.
final class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()

    var commandHandler: ((WatchCommand) -> Void)?

    private var session: WCSession?

    private override init() {
        super.init()

        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
        self.session = session
        print("[iPhone] WatchConnectivityManager initialized, WCSession activating…")
    }

    func publish(session timerSession: TimerSession?) {
        guard let session else { return }

        do {
            let context = makeContext(for: timerSession)
            try session.updateApplicationContext(context)
            print("[iPhone] Published context to Watch: isRunning=\(context["isRunning"] ?? "nil"), stageName=\(context["stageName"] ?? "nil")")
        } catch {
            print("Unable to update Apple Watch timer state: \(error.localizedDescription)")
        }
    }

    private func makeContext(for timerSession: TimerSession?) -> [String: Any] {
        guard let timerSession, let stage = timerSession.currentStage,
              timerSession.state == .running || timerSession.state == .paused else {
            return ["isRunning": false, "routineName": "IntervalLoop", "stageName": "", "stageType": "", "timeRemaining": 0, "stageIndex": 0, "totalStages": 0, "loopDescription": ""]
        }

        return [
            "isRunning": timerSession.state == .running,
            "routineName": timerSession.configuration.name,
            "stageName": stage.name,
            "stageType": stage.type.localizedName,
            "timeRemaining": Int(ceil(timerSession.timeRemaining)),
            "stageIndex": timerSession.currentStageIndex,
            "totalStages": timerSession.configuration.totalStages,
            "loopDescription": timerSession.configuration.loopDescription(for: timerSession.currentStageIndex) ?? ""
        ]
    }

    private func receiveCommand(from message: [String: Any]) {
        guard let rawValue = message["command"] as? String,
              let command = WatchCommand(rawValue: rawValue) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.commandHandler?(command)
        }
    }
}

enum WatchCommand: String {
    case pause, resume, previous, next, stop
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("[iPhone] WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("[iPhone] WCSession activated. isPaired=\(session.isPaired), isWatchAppInstalled=\(session.isWatchAppInstalled)")
        }
    }
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("[iPhone] didReceiveMessage: \(message)")
        receiveCommand(from: message)
    }
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("[iPhone] didReceiveMessage (with reply): \(message)")
        receiveCommand(from: message)
        replyHandler([:])
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) { receiveCommand(from: userInfo) }
}