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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("settings.volume", comment: "Volume"))
                        
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(.secondary)
                            
                            Slider(
                                value: Binding(
                                    get: { Double(audioManager.volume) },
                                    set: { audioManager.setVolume(Float($0)) }
                                ),
                                in: 0...1
                            )
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.secondary)
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
                        NSLocalizedString("settings.keep_screen_on", comment: "Keep Screen On"),
                        isOn: $keepScreenOn
                    )
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
                            .foregroundColor(.secondary)
                    }
                    
                    Link(
                        NSLocalizedString("settings.support", comment: "Support"),
                        destination: URL(string: "https://example.com/support")!
                    )
                    
                    Link(
                        NSLocalizedString("settings.privacy", comment: "Privacy Policy"),
                        destination: URL(string: "https://example.com/privacy")!
                    )
                } header: {
                    Text(NSLocalizedString("settings.about", comment: "About"))
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
