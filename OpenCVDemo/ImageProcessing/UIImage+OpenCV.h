//
//  UIImage+OpenCV.h
//  OpenCVDemo
//
//  Created by Murphy Zheng on 17/8/23.
//  Copyright © 2017年 mieasy. All rights reserved.
//

#import "opencv2/opencv.hpp"
#import "opencv2/imgproc/types_c.h"
#import "opencv2/imgcodecs/ios.h"
#import <UIKit/UIKit.h>

@interface UIImage (OpenCV)

@property (nonatomic, readonly) cv::Mat CVMat;

@property (nonatomic, readonly) cv::Mat CVGrayscaleMat;

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;

@end
