import CoreML
import Vision
import Accelerate

class UformerProcessor {
    private var model: VNCoreMLModel?
    private var request: VNCoreMLRequest?

    init() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .cpuOnly

            let coreMLModel = try Uformer(configuration: config)
            model = try VNCoreMLModel(for: coreMLModel.model)
            request = VNCoreMLRequest(model: model!)
            request?.imageCropAndScaleOption = .scaleFill
        } catch {
            print("Error loading model: \(error)")
        }
    }

    func processImage(_ image: CVPixelBuffer) -> MLMultiArray? {
        autoreleasepool {
            guard let request = request else { return nil }

            let handler: VNImageRequestHandler
            do {
                handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
                try handler.perform([request])
            } catch {
                print("Error performing request: \(error)")
                return nil
            }

            guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                  let output = results.first?.featureValue.multiArrayValue else {
                return nil
            }

            return output
        }
    }

    func prepareInput(image: UIImage) -> CVPixelBuffer? {
        // 1. Конвертация UIImage в CVPixelBuffer (512x512)
        let size = CGSize(width: 512, height: 512)
        guard let resizedImage = image.downsampled(to: size),
              let pixelBuffer = resizedImage.pixelBuffer(width: 512, height: 512) else {
            return nil
        }

        // 2. Добавление 4-го канала (если нужно)
        return pixelBuffer
    }

    func processOutput(_ output: MLMultiArray) -> UIImage? {
        // Пример для 6-канального вывода (первые 3 канала - RGB)
        let height = 512
        let width = 512
        let channels = 6

        // Конвертация MLMultiArray в UIImage
        var imageBytes = [UInt8](repeating: 0, count: height * width * 4)

        // Обработка каждого пикселя
        for y in 0..<height {
            for x in 0..<width {
                let r = output[[0, 0, y, x] as [NSNumber]].floatValue
                let g = output[[0, 1, y, x] as [NSNumber]].floatValue
                let b = output[[0, 2, y, x] as [NSNumber]].floatValue

                let index = (y * width + x) * 4
                imageBytes[index] = UInt8(max(0, min(255, r * 255)))
                imageBytes[index+1] = UInt8(max(0, min(255, g * 255)))
                imageBytes[index+2] = UInt8(max(0, min(255, b * 255)))
                imageBytes[index+3] = 255 // Alpha
            }
        }

        return UIImage.fromByteArray(imageBytes, width: width, height: height)
    }
}

extension UIImage {
    func downsampled(to size: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let data = self.pngData(),
              let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }

        let maxDimension = max(size.width, size.height)
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }

    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            options as CFDictionary,
            &pixelBuffer
        )

        guard let buffer = pixelBuffer else { return nil }
        CVPixelBufferLockBaseAddress(buffer, [])

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])

        return buffer
    }

    static func fromByteArray(_ bytes: [UInt8], width: Int, height: Int) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let providerRef = CGDataProvider(data: Data(bytes: bytes, count: bytes.count) as CFData),
              let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: providerRef,
                decode: nil,
                shouldInterpolate: false,
                intent: .defaultIntent
              ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
