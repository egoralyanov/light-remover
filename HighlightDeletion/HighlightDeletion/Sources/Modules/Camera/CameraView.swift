import SwiftUI

struct CameraView: View {

    @StateObject private var cameraController = CameraSessionController()

    @State private var isProcessing = false
    @State private var thresholdValue = 240.0

    var body: some View {
        ZStack {
            if let processedImage = cameraController.processedImage, isProcessing {
                Image(uiImage: processedImage)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
            } else {
                CameraPreview(session: cameraController.session)
                    .edgesIgnoringSafeArea(.all)
            }

            VStack {
                Spacer()
                if isProcessing {
                    Slider(
                        value: $thresholdValue,
                        in: 100...255,
                        step: 10
                    ) {
                        Text("Threshold")
                    } onEditingChanged: { _ in
                        cameraController.setThreshold(Int(thresholdValue))
                    }
                    .padding(.horizontal, 40)

                    Text(thresholdValue.description)
                }
                Button(action: {
                    isProcessing.toggle()
                    cameraController.setProcessing(isProcessing)
                }) {
                    Text(isProcessing ? "Отключить обработку" : "Включить обработку")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                }.padding(.bottom, 40)
            }
        }
        .onAppear {
            cameraController.configure()
        }
    }
}
