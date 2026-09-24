//
//  AudioManager.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import Foundation
import AVFoundation
import Combine

/// Sound effect types
/// 音效類型
enum SoundEffect: String {
    case stageTransition = "beep"
    case countdown = "tick"
    case completion = "chime"
    
    var filename: String {
        rawValue
    }
}

/// Audio manager for voice announcements and sound effects
/// 語音提示和音效的音訊管理器
class AudioManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared = AudioManager()
    
    // MARK: - Published Properties
    @Published var isEnabled: Bool = true
    @Published var voiceEnabled: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var volume: Float = 1.0
    
    // MARK: - Private Properties
    private var synthesizer = AVSpeechSynthesizer()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var currentLanguage: Language = .english
    /// A near-silent looping player that keeps the audio session (and therefore
    /// the process + RunLoop) alive while the app is in the background.
    private var silentPlayer: AVAudioPlayer?
    /// Whether background keep-alive audio is currently requested.
    private var backgroundAudioActive = false
    /// Tracks how many sound effects / speech utterances are currently active.
    /// When this drops back to 0 we un-duck other apps' audio.
    private var activeSoundCount = 0
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        configureSynthesizer()
        configureAudioSession()
        loadSettings()
        
        // Listen for audio session interruptions (e.g. phone call, Siri) so we
        // can resume the silent keep-alive player afterwards.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }
    
    // MARK: - Public Methods
    
    /// Speak text using text-to-speech
    /// 使用文字轉語音朗讀文字
    func speak(_ text: String, language: Language? = nil) {
        guard isEnabled && voiceEnabled else { return }

        let lang = language ?? currentLanguage
        
        // Temporarily duck other audio while speaking
        beginDucking()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang.code)
        utterance.rate = 0.5 // Slightly slower for clarity
        utterance.volume = volume
        
        synthesizer.speak(utterance)
    }

    var isVoiceEnabled: Bool { isEnabled && voiceEnabled }
    
    /// Stop current speech
    /// 停止當前語音
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            // endDucking() will be called by the didCancel delegate
        }
    }

    /// Stop any currently playing sound effects.
    func stopSounds() {
        let count = audioPlayers.count
        audioPlayers.values.forEach { $0.stop() }
        audioPlayers.removeAll()
        // Manually adjust since stopping doesn't trigger the delegate
        for _ in 0..<count {
            endDucking()
        }
    }
    
    /// Play sound effect
    /// 播放音效
    func playSound(_ sound: SoundEffect) {
        guard isEnabled && soundEnabled else { return }
        guard Bundle.main.url(forResource: sound.filename, withExtension: "mp3") != nil else {
            return
        }

        // Temporarily duck other audio while playing
        beginDucking()

        loadAndPlaySound(sound)
    }

    /// Play exactly one sound for the settings preview.
    func previewSound(_ sound: SoundEffect) {
        stopSounds()
        playSound(sound)
    }

    /// Recover speech after iOS has interrupted audio while the app was locked
    /// or in the background.
    func resumeAfterAppBecomesActive() {
        configureAudioSession()
        // Only recreate the synthesizer if it seems stuck; a working one should
        // be left alone so queued utterances are not lost.
        if !synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            synthesizer = AVSpeechSynthesizer()
            configureSynthesizer()
        }
    }

    /// Pre-switch the audio session to ducking mode without starting a sound.
    /// Call ~1 s before the first countdown number so the expensive
    /// `setCategory` / `setActive` switch is already done.
    /// 預先切換到 duck 模式，在第一個倒數數字前約 1 秒呼叫，讓昂貴的
    /// audio session 切換提前完成。
    func preDuck() {
        guard activeSoundCount == 0 else { return } // already ducking
        beginDucking()
        // Schedule un-duck after a short window in case no sound actually fires
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self, self.activeSoundCount == 1 else { return }
            self.endDucking()
        }
    }

    // MARK: - Background Keep-Alive

    /// Start a near-silent audio loop so iOS keeps the audio session alive in
    /// the background. Must be called **while the app is still in the foreground**
    /// (e.g. when the workout starts) so that audio is already playing before
    /// the app transitions to the background.
    func startBackgroundAudio() {
        guard silentPlayer == nil else { return }
        backgroundAudioActive = true

        configureAudioSession()

        guard let url = Bundle.main.url(forResource: "silence", withExtension: "mp3") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1   // loop forever
            player.volume = 0.01        // near-silent
            player.prepareToPlay()
            player.play()
            silentPlayer = player
        } catch {
            #if DEBUG
            print("Failed to start background audio loop: \(error)")
            #endif
        }
    }

    /// Stop the background keep-alive audio loop.
    func stopBackgroundAudio() {
        backgroundAudioActive = false
        silentPlayer?.stop()
        silentPlayer = nil
    }
    
    /// Set language for voice announcements
    /// 設置語音提示的語言
    func setLanguage(_ language: Language) {
        currentLanguage = language
        saveSettings()
    }
    
    /// Get current language
    /// 獲取當前語言
    func getCurrentLanguage() -> Language {
        currentLanguage
    }
    
    /// Toggle voice announcements
    /// 切換語音提示
    func toggleVoice() {
        voiceEnabled.toggle()
        saveSettings()
    }
    
    /// Toggle sound effects
    /// 切換音效
    func toggleSound() {
        soundEnabled.toggle()
        saveSettings()
    }
    
    /// Set volume (0.0 to 1.0)
    /// 設置音量（0.0 到 1.0）
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        saveSettings()
    }
    
    // MARK: - Private Methods
    
    /// Configure audio session in normal (non-ducking) mode.
    /// Uses `.mixWithOthers` so other apps' audio plays at full volume.
    /// 配置音訊會話為正常模式，不影響其他 app 的音量。
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try audioSession.setActive(true, options: [])
        } catch {
            #if DEBUG
            print("Failed to configure audio session: \(error)")
            #endif
        }
    }
    
    /// Temporarily switch to ducking mode — lowers other apps' audio while
    /// our sound effect or voice is playing.
    /// 暫時切換到 duck 模式 — 在我們的音效或語音播放期間壓低其他 app 音量。
    private func beginDucking() {
        activeSoundCount += 1
        // Only switch category if this is the first active sound
        guard activeSoundCount == 1 else { return }
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers]
            )
            try audioSession.setActive(true, options: [])
        } catch {
            #if DEBUG
            print("Failed to begin ducking: \(error)")
            #endif
        }
    }
    
    /// Called when a sound effect or speech utterance finishes. When no more
    /// active sounds remain, switch back to normal (non-ducking) mode so
    /// other apps' audio returns to full volume.
    /// 當音效或語音結束時呼叫。當沒有活躍的聲音時，切回正常模式讓其他 app 音量恢復。
    private func endDucking() {
        activeSoundCount = max(0, activeSoundCount - 1)
        guard activeSoundCount == 0 else { return }
        do {
            let audioSession = AVAudioSession.sharedInstance()
            // Deactivate with .notifyOthersOnDeactivation so the ducked apps
            // know they can restore their volume.
            try audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
            // Re-activate in mix mode (needed for the silent keep-alive loop)
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try audioSession.setActive(true, options: [])
        } catch {
            #if DEBUG
            print("Failed to end ducking: \(error)")
            #endif
        }
    }

    /// Handle audio session interruptions (phone call, Siri, etc.).
    /// When the interruption ends, restart the silent keep-alive player.
    @objc private func handleAudioInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeRaw = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeRaw) else {
            return
        }

        switch type {
        case .began:
            // Audio interrupted — nothing to do, iOS pauses our players automatically.
            break
        case .ended:
            // Interruption ended — reactivate the session and restart the silent player.
            let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
            if AVAudioSession.InterruptionOptions(rawValue: options).contains(.shouldResume) ||
               backgroundAudioActive {
                configureAudioSession()
                silentPlayer?.play()
            }
        @unknown default:
            break
        }
    }

    private func configureSynthesizer() {
        synthesizer.delegate = self
    }
    
    /// Load and play sound effect
    /// 載入並播放音效
    private func loadAndPlaySound(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(
            forResource: sound.filename,
            withExtension: "mp3"
        ) else {
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.volume = volume
            player.prepareToPlay()
            let identifier = "\(sound.rawValue).\(UUID().uuidString)"
            audioPlayers[identifier] = player

            if !player.play() {
                audioPlayers.removeValue(forKey: identifier)
                #if DEBUG
                print("Failed to start sound: \(sound.filename)")
                #endif
            }
        } catch {
            #if DEBUG
            print("Failed to load sound: \(error)")
            #endif
        }
    }
    
    /// Load settings from UserDefaults
    /// 從 UserDefaults 載入設定
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        isEnabled = defaults.object(forKey: "audioEnabled") as? Bool ?? true
        voiceEnabled = defaults.object(forKey: "voiceEnabled") as? Bool ?? true
        soundEnabled = defaults.object(forKey: "soundEnabled") as? Bool ?? true
        volume = defaults.object(forKey: "audioVolume") as? Float ?? 1.0
        
        if let langCode = defaults.string(forKey: "audioLanguage"),
           let language = Language(rawValue: langCode) {
            currentLanguage = language
        } else {
            // Auto-detect system language
            currentLanguage = detectSystemLanguage()
        }
    }
    
    /// Save settings to UserDefaults
    /// 保存設定到 UserDefaults
    private func saveSettings() {
        let defaults = UserDefaults.standard
        
        defaults.set(isEnabled, forKey: "audioEnabled")
        defaults.set(voiceEnabled, forKey: "voiceEnabled")
        defaults.set(soundEnabled, forKey: "soundEnabled")
        defaults.set(volume, forKey: "audioVolume")
        defaults.set(currentLanguage.rawValue, forKey: "audioLanguage")
    }
    
    /// Detect system language
    /// 偵測系統語言
    private func detectSystemLanguage() -> Language {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        
        if preferredLanguage.hasPrefix("zh") {
            // Check for Traditional Chinese
            if preferredLanguage.contains("Hant") || preferredLanguage.contains("TW") || preferredLanguage.contains("HK") {
                return .traditionalChinese
            }
        }
        
        return .english
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        // Speech started
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        endDucking()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        endDucking()
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayers = audioPlayers.filter { $0.value !== player }
        endDucking()
    }
}

// MARK: - Language Support

/// Supported languages for voice announcements
/// 支援的語音提示語言
enum Language: String, CaseIterable {
    case english = "en"
    case traditionalChinese = "zh-Hant"
    
    var code: String {
        switch self {
        case .english:
            return "en-US"
        case .traditionalChinese:
            return "zh-TW"
        }
    }
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .traditionalChinese:
            return "繁體中文"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .english:
            return NSLocalizedString("language.english", comment: "English")
        case .traditionalChinese:
            return NSLocalizedString("language.chinese", comment: "Traditional Chinese")
        }
    }
}

// MARK: - Preload Sounds Helper

extension AudioManager {
    /// Preload all sound effects
    /// 預載入所有音效
    func preloadSounds() {
        for sound in [SoundEffect.stageTransition, .countdown, .completion] {
            guard let url = Bundle.main.url(
                forResource: sound.filename,
                withExtension: "mp3"
            ) else { continue }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                // Validate the asset at launch. Playback creates a fresh player.
                _ = player
            } catch {
                #if DEBUG
                print("Failed to preload sound \(sound.filename): \(error)")
                #endif
            }
        }
    }
}

// Made with Bob
