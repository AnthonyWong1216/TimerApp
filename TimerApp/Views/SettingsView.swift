//
//  SettingsView.swift
//  IntervalTimer
//
//  Created by Bob on 2026-06-04.
//

import SwiftUI

/// Settings view for app configuration
/// 應用配置的設定視圖
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    @AppStorage("keepScreenOn") private var keepScreenOn = true
    @AppStorage("useDarkMode") private var useDarkMode = true
    @AppStorage("timerNumberFont") private var timerNumberFont = TimerNumberFont.rounded.rawValue
    @AppStorage("timerProgressStyle") private var timerProgressStyle = TimerProgressStyle.circle.rawValue
    @AppStorage("countdownAnnouncement") private var countdownAnnouncement = CountdownAnnouncement.three.rawValue
    
    var body: some View {
        NavigationStack {
            Form {
                // Audio settings
                Section {
                    Toggle(
                        NSLocalizedString("settings.voice_enabled", comment: "Voice Announcements"),
                        isOn: $audioManager.voiceEnabled
                    )
                    
                    Toggle(
                        NSLocalizedString("settings.sound_enabled", comment: "Sound Effects"),
                        isOn: $audioManager.soundEnabled
                    )

                    HStack {
                        Text(NSLocalizedString("settings.sound_test", comment: "Test sound effects"))
                        Spacer()
                        Button(NSLocalizedString("settings.sound_test_tick", comment: "Tick")) {
                            audioManager.previewSound(.countdown)
                        }
                        Button(NSLocalizedString("settings.sound_test_beep", comment: "Beep")) {
                            audioManager.previewSound(.stageTransition)
                        }
                        Button(NSLocalizedString("settings.sound_test_chime", comment: "Chime")) {
                            audioManager.previewSound(.completion)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("settings.volume", comment: "Volume"))
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundStyle(.primary.opacity(0.75))
                            
                            Slider(
                                value: Binding(
                                    get: { Double(audioManager.volume) },
                                    set: { audioManager.setVolume(Float($0)) }
                                ),
                                in: 0...1
                            )
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundStyle(.primary.opacity(0.75))
                        }
                    }
                    
                    Picker(
                        NSLocalizedString("settings.language", comment: "Language"),
                        selection: Binding(
                            get: { audioManager.getCurrentLanguage() },
                            set: { audioManager.setLanguage($0) }
                        )
                    ) {
                        ForEach(Language.allCases, id: \.self) { language in
                            Text(language.localizedDisplayName).tag(language)
                        }
                    }
                } header: {
                    Text(NSLocalizedString("settings.audio", comment: "Audio"))
                } footer: {
                    Text(NSLocalizedString("settings.audio_footer", comment: "Configure voice announcements and sound effects"))
                }
                
                // Display settings
                Section {
                    Toggle(
                        NSLocalizedString("settings.dark_mode", comment: "Dark Mode"),
                        isOn: $useDarkMode
                    )

                    Toggle(
                        NSLocalizedString("settings.keep_screen_on", comment: "Keep Screen On"),
                        isOn: $keepScreenOn
                    )

                    Picker(NSLocalizedString("settings.timer_font", comment: "Timer Font"), selection: $timerNumberFont) {
                        ForEach(TimerNumberFont.allCases) { font in
                            Text(font.localizedName).tag(font.rawValue)
                        }
                    }

                    Picker(NSLocalizedString("settings.timer_progress", comment: "Countdown Style"), selection: $timerProgressStyle) {
                        ForEach(TimerProgressStyle.allCases) { style in
                            Text(style.localizedName).tag(style.rawValue)
                        }
                    }

                    Picker(NSLocalizedString("settings.countdown", comment: "Countdown announcement"), selection: $countdownAnnouncement) {
                        ForEach(CountdownAnnouncement.allCases) { option in
                            Text(option.localizedName).tag(option.rawValue)
                        }
                    }
                } header: {
                    Text(NSLocalizedString("settings.display", comment: "Display"))
                } footer: {
                    Text(NSLocalizedString("settings.display_footer", comment: "Prevent screen from dimming during workout"))
                }
                
                // Notifications
                Section {
                    HStack {
                        Text(NSLocalizedString("settings.notifications", comment: "Notifications"))
                        
                        Spacer()
                        
                        if notificationManager.isAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Button(NSLocalizedString("settings.enable", comment: "Enable")) {
                                requestNotifications()
                            }
                        }
                    }

                    Button(NSLocalizedString("settings.open_notification_settings", comment: "Open notification settings")) {
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                    }
                } header: {
                    Text(NSLocalizedString("settings.notifications_header", comment: "Notifications"))
                } footer: {
                    Text(NSLocalizedString("settings.notifications_footer", comment: "Receive notifications for stage changes"))
                }
                
                // About section
                Section {
                    HStack {
                        Text(NSLocalizedString("settings.version", comment: "Version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.primary.opacity(0.75))
                    }
                    
                    Text(NSLocalizedString("settings.support", comment: "Support"))
                    Text(NSLocalizedString("settings.privacy", comment: "Privacy Policy"))
                } header: {
                    Text(NSLocalizedString("settings.about", comment: "About"))
                } footer: {
                    Text(NSLocalizedString("settings.links_coming_soon", comment: "Links coming soon"))
                }
            }
            .navigationTitle(NSLocalizedString("settings.title", comment: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("settings.done", comment: "Done")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func requestNotifications() {
        Task {
            await notificationManager.requestAuthorization()
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}

// Made with Bob
