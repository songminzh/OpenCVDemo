//
//  faceRecognition.h
//  OpenCVDemo
//
//  Created by Murphy Zheng on 17/9/6.
//  Copyright © 2017年 mieasy. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface faceRecognition : NSObject

+ (UIImage *)convertImage: (UIImage *)image;

+ (UIImage *)faceDetectForImage: (UIImage *)image;

+ (NSArray *)facePointDetectForImage: (UIImage *)image;

@end
