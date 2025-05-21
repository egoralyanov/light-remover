#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (UIImage *)processImage:(UIImage *)image  withThreshold:(int)thresholdValue;
@end

NS_ASSUME_NONNULL_END
