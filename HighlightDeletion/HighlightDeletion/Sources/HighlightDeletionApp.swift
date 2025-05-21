import SwiftUI

@main
struct HighlightDeletionApp: App {

    @State private var isLaunching = true

    var body: some Scene {
        WindowGroup {
            if isLaunching {
                LaunchView(isLaunching: $isLaunching)
            } else {
                TabView {
                    Tab("Settings", systemImage: "gear") {
                        SettingsView()
                    }

                    Tab("Video", systemImage: "video.fill") {
                        CameraView()
                    }

                    Tab("Photo", systemImage: "photo") {
                        ImageProcessingTestView()
                    }
                }
            }
        }
    }
}
