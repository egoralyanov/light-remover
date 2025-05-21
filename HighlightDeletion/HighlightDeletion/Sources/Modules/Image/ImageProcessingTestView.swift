import SwiftUI
import PhotosUI
//import opencv2
//import torch
//import LibTorch

struct ImageProcessingTestView: View {

    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var threshold: Double = 240.0
    @State private var showPhotoPicker = false
    @State private var showOrig = false
    @State private var showProcessed = false

    var body: some View {
        NavigationView {
            VStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .padding()
                        .onTapGesture { showOrig = true }
                        .fullScreenCover(isPresented: $showOrig) {
                            FullScreenImageView(image: image)
                        }
                } else {
                    Text("Выберите изображение")
                        .padding()
                }

                if let result = processedImage {
                    Text("Результат обработки:")
                    Image(uiImage: result)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .padding()
                        .onTapGesture { showProcessed = true }
                        .fullScreenCover(isPresented: $showProcessed) {
                            FullScreenImageView(image: result)
                        }
                }

                Slider(value: $threshold, in: 100...255, step: 5) {
                    Text("Порог")
                } onEditingChanged: { _ in
                    applyProcessing()
                }
                .padding(.horizontal)

                Text("Порог: \(Int(threshold))")

                Button("Выбрать фото из галереи") {
                    showPhotoPicker = true
                }
                .padding()
            }
            .navigationTitle("Тест обработки")
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(image: $selectedImage, onImagePicked: {
                    applyProcessing()
                })
            }
        }
    }

    private func applyProcessing() {
//        pytorchProcessing()
//        coreMLProcessing()
        guard let image = selectedImage else { return }
        processedImage = OpenCVWrapper.processImage(image, withThreshold: Int32(threshold))
    }

    private func coreMLProcessing() {
        guard let image = selectedImage else { return }

        let processor = UformerProcessor()

        guard let inputBuffer = processor.prepareInput(image: image),
              let output = processor.processImage(inputBuffer),
              let resultImage = processor.processOutput(output) else {
            print("Processing failed")
            return
        }

        processedImage = resultImage

//        processor.processImage(image) { resultImage in
//            processedImage = resultImage
//            print("got result: \(resultImage)")
//        }
    }

//    private func pytorchProcessing() {
//        guard let image = selectedImage else { return }
//
//
//    }
}
