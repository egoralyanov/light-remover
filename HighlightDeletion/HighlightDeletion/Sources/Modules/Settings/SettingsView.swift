import SwiftUI

enum ImageProcessingSolution: String, Identifiable, CaseIterable {
    case openCV
    case coreML

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .openCV:
            return "OpenCV"
        case .coreML:
            return "CoreML"
        }
    }
}

struct SettingsView: View {

    @AppStorage("imageProcessingSolution") private var imageProcessingSolution: ImageProcessingSolution = .openCV

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Solution", selection: $imageProcessingSolution) {
                        ForEach(ImageProcessingSolution.allCases, id: \.self) { solution in
                            Text(solution.title)
                                .tag(solution)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Solution")
                }
            }
            .navigationTitle("Settings")
        }
        .background(Color.primaryBackground)
    }
}
