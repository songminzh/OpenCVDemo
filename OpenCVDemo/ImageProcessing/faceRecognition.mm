//
//  faceRecognition.m
//  OpenCVDemo
//
//  Created by Murphy Zheng on 17/9/6.
//  Copyright © 2017年 mieasy. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

#import "faceRecognition.h"
#import "UIImage+OpenCV.h"

@implementation faceRecognition

+ (UIImage *)convertImage: (UIImage *)image {
    
    // 初始化一个图片的二维矩阵cvImage
    cv::Mat cvImage;
    
    // 将图片UIImage对象转为Mat对象
    cvImage = [UIImage cvMatFromUIImage:image];
    
    if (!cvImage.empty()) {
        cv::Mat gray;
        
        // 进一步将图片转为灰度显示
        cv::cvtColor(cvImage, gray, CV_RGB2GRAY);
        
        // 利用搞死滤镜去除边缘
        cv::GaussianBlur(gray, gray, cv::Size(5, 5), 1.2, 1.2);
        
        // 计算画布
        cv::Mat edges;
        cv::Canny(gray, edges, 0, 50);
        
        // 使用白色填充
        cvImage.setTo(cv::Scalar::all(225));
        
        // 修改边缘颜色
        cvImage.setTo(cv::Scalar(0,128,255,255),edges);
        
        // 将Mat转换为UIImage
        return [UIImage imageWithCVMat:cvImage];
    }
    
    return nil;
}

+ (NSArray*)facePointDetectForImage:(UIImage*)image {
    
    static cv::CascadeClassifier faceDetector;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 添加xml文件
        NSString* cascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        faceDetector.load([cascadePath UTF8String]);
    });
    
    cv::Mat faceImage;
    faceImage = [UIImage cvMatFromUIImage:image];
    
    // 转为灰度
    cv::Mat gray;
    cvtColor(faceImage, gray, CV_BGR2GRAY);
    
    // 检测人脸并储存
    std::vector<cv::Rect>faces;
    faceDetector.detectMultiScale(gray, faces,1.1,2,CV_HAAR_FIND_BIGGEST_OBJECT,cv::Size(30,30));
    
    NSMutableArray *array = [NSMutableArray array];
    
    for(unsigned int i= 0;i < faces.size();i++)
    {
        const cv::Rect& face = faces[i];
        float height = (float)faceImage.rows;
        float width = (float)faceImage.cols;
        CGRect rect = CGRectMake(face.x/width, face.y/height, face.width/width, face.height/height);
        [array addObject:[NSNumber valueWithCGRect:rect]];
    }
    
    return [array copy];
}

+ (UIImage*)faceDetectForImage:(UIImage*)image {
    
    static cv::CascadeClassifier faceDetector;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString* cascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
        faceDetector.load([cascadePath UTF8String]);
    });
    
    cv::Mat faceImage;
    faceImage = [UIImage cvMatFromUIImage:image];
    
    // 转为灰度
    cv::Mat gray;
    cvtColor(faceImage, gray, CV_BGR2GRAY);
    
    // 检测人脸并储存
    std::vector<cv::Rect>faces;
    faceDetector.detectMultiScale(gray, faces,1.1,2,0,cv::Size(30,30));
    
    // 在每个人脸上画一个红色四方形
    for(unsigned int i= 0;i < faces.size();i++)
    {
        const cv::Rect& face = faces[i];
        cv::Point tl(face.x,face.y);
        cv::Point br = tl + cv::Point(face.width,face.height);
        // 四方形的画法
        cv::Scalar magenta = cv::Scalar(255, 0, 0, 255);
        cv::rectangle(faceImage, tl, br, magenta, 2, 2, 0);
    }
    
    return [UIImage imageWithCVMat:faceImage];
}

@end
