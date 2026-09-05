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
    private let synthesizer = AVSpeechSynthesizer()
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var currentLanguage: Language = .english
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        synthesizer.delegate = self
        configureAudioSession()
        loadSettings()
    }
    
    // MARK: - Public Methods
    
    /// Speak text using text-to-speech
    /// 使用文字轉語音朗讀文字
    func speak(_ text: String, language: Language? = nil) {
        guard isEnabled && voiceEnabled else { return }
        
        let lang = language ?? currentLanguage
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang.code)
        utterance.rate = 0.5 // Slightly slower for clarity
        utterance.volume = volume
        
        synthesizer.speak(utterance)
    }
    
    /// Stop current speech
    /// 停止當前語音
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// Play sound effect
    /// 播放音效
    func playSound(_ sound: SoundEffect) {
        guard isEnabled && soundEnabled else { return }
        
        // Try to get existing player or create new one
        if let player = audioPlayers[sound.rawValue] {
            player.currentTime = 0
            player.volume = volume
            player.play()
        } else {
            loadAndPlaySound(sound)
        }
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
    
    /// Configure audio session for background playback
    /// 配置音訊會話以支援背景播放
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    /// Load and play sound effect
    /// 載入並播放音效
    private func loadAndPlaySound(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(
            forResource: sound.filename,
            withExtension: "mp3"
        ) else {
            print("Sound file not found: \(sound.filename)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            player.play()
            
            audioPlayers[sound.rawValue] = player
        } catch {
            print("Failed to load sound: \(error)")
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
        // Speech finished
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        // Speech cancelled
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
                audioPlayers[sound.rawValue] = player
            } catch {
                print("Failed to preload sound \(sound.filename): \(error)")
            }
        }
    }
}

// Made with Bob
