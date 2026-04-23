//
//  declockApp.swift
//  declock
//
//  Created by 福寄典明 on 2026/04/23.
//

import SwiftUI
#if os(macOS)
import ServiceManagement
#endif

@main
struct declockApp: App {
    var body: some Scene {
        #if os(macOS)
        WindowGroup("DeClock") {
            ContentView()
        }
        .defaultSize(width: 220, height: 220)
        .windowResizability(.contentMinSize)

        Settings {
            StartupSettingsView()
        }
        #else
        WindowGroup("DeClock") {
            ContentView()
        }
        #endif
    }
}

#if os(macOS)
struct StartupSettingsView: View {
    @State private var launchesAtLogin = false
    @State private var serviceStatus = SMAppService.mainApp.status
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Toggle("ログイン時に DeClock を起動", isOn: launchAtLoginBinding)

            if serviceStatus == .requiresApproval {
                Text("システム設定でログイン項目の承認が必要です。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(20)
        .frame(width: 360)
        .onAppear {
            refreshLaunchAtLoginStatus()
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { launchesAtLogin },
            set: updateLaunchAtLogin
        )
    }

    private static func isLaunchAtLoginEnabled(for status: SMAppService.Status) -> Bool {
        return status == .enabled || status == .requiresApproval
    }

    private func updateLaunchAtLogin(_ isEnabled: Bool) {
        launchesAtLogin = isEnabled

        do {
            let status = SMAppService.mainApp.status

            if isEnabled {
                if status != .enabled && status != .requiresApproval {
                    try SMAppService.mainApp.register()
                }
            } else {
                if status == .enabled || status == .requiresApproval {
                    try SMAppService.mainApp.unregister()
                }
            }

            errorMessage = nil
        } catch {
            errorMessage = "設定を変更できませんでした: \(error.localizedDescription)"
        }

        refreshLaunchAtLoginStatus()
    }

    private func refreshLaunchAtLoginStatus() {
        serviceStatus = SMAppService.mainApp.status
        launchesAtLogin = Self.isLaunchAtLoginEnabled(for: serviceStatus)
    }
}
#endif
