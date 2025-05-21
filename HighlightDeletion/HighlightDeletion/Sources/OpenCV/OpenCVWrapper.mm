#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

using namespace cv;

@implementation OpenCVWrapper

+ (UIImage *)processImage:(UIImage *)image withThreshold:(int)thresholdValue {
    // Преобразуем UIImage в cv::Mat
    cv::Mat mat;
    UIImageToMat(image, mat);

    // Убираем альфа-канал, если он есть, и конвертируем в 3-канальное изображение (RGB)
    if (mat.channels() == 4) {
        cv::Mat rgbImage;
        cv::cvtColor(mat, rgbImage, COLOR_BGRA2BGR);  // Преобразуем в RGB (без альфа-канала)
        mat = rgbImage;  // Переназначаем mat, чтобы работать с 3-канальным изображением
    }

    // Преобразуем изображение в 8-битное 3-канальное изображение
    cv::Mat convertedImage;
    mat.convertTo(convertedImage, CV_8UC3);

    // Преобразуем изображение в градации серого
    cv::Mat gray;
    cv::cvtColor(convertedImage, gray, COLOR_BGR2GRAY);

    // Создаем маску для бликов (яркость > thresholdValue)
    cv::Mat mask;
    cv::threshold(gray, mask, thresholdValue, 255, THRESH_BINARY);

    // Убедимся, что маска 8-битная одно-канальная
    mask.convertTo(mask, CV_8UC1);  // Это гарантирует правильный формат для маски

    // Восстановление бликов с помощью inpaint
    cv::Mat result;
    cv::inpaint(convertedImage, mask, result, 3, INPAINT_TELEA);  // Обработка изображения

    // Преобразуем результат обратно в UIImage
    UIImage *resultImage = MatToUIImage(result);
    return resultImage;
}

@end
