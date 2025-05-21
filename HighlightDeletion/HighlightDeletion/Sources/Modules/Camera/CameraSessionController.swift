import AVFoundation
import UIKit
import Combine

final class CameraSessionController: NSObject, ObservableObject {

    @Published var processedImage: UIImage? // Храним обработанное изображение

    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private var isProcessing = false
    private var thresholdValue = 240
    private var solution: ImageProcessingSolution = .openCV

    func configure() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }

        session.addInput(input)

        if session.canAddOutput(output) {
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(output)
        }

        session.commitConfiguration()
        session.startRunning()
    }

    func setProcessing(_ enabled: Bool) {
        self.isProcessing = enabled
    }

    func setThreshold(_ value: Int) {
        self.thresholdValue = value
    }

    func setSolution(_ solution: ImageProcessingSolution) {
        self.solution = solution
    }

    private func processImage(_ image: UIImage) -> UIImage? {
//        switch solution {
//        case .openCV:
            return OpenCVWrapper.processImage(image, withThreshold: Int32(thresholdValue))

//        case .coreML:
//            return nil
//        }
    }
}

extension CameraSessionController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isProcessing else { return }

        connection.videoOrientation = .portrait

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Преобразуем в UIImage
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        let uiImage = UIImage(cgImage: cgImage)

        // Применяем обработку через OpenCV/CoreML
        let processedImage = processImage(uiImage)

        // Обновляем @Published переменную
        DispatchQueue.main.async {
            self.processedImage = processedImage
        }
    }
}
