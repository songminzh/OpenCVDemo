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
#import <opencv2/highgui/highgui_c.h>
#include "opencv2/core/core.hpp"
#import <UIKit/UIKit.h>

typedef unsigned char BYTE;

#define CMV_MAX_BUF 1024
#define ORI_WIDTH 1920
#define ORI_HEIGHT 1080

#define INDEX_MASK		    0x001FFFFF    //索引掩膜
#define	WEIGHT_MASK		    0xFFE00000    //权重掩膜

#define IMAGE_NUM_MASK      0x00000003    //当前点拼接像素
#define IMAGE_INDEX1_MASK   0x0000000C    //第一幅影像索引
#define IMAGE_INDEX2_MASK   0x00000030    //第二幅影像索引
#define IMAGE_INDEX3_MASK   0x000000C0    //第三幅影像索引

@interface UIImage (OpenCV)

@property (nonatomic, readonly) cv::Mat CVMat;

@property (nonatomic, readonly) cv::Mat CVGrayscaleMat;

/**
 cv::Mat --> UIImage
 
 @return UIImage
 */
+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;

/**
 UIImage --> cv::Mat
 
 @param image image
 @return cv::Mat
 */
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;


/**
 UIImage --> cv::Mat (gray)

 @param image image
 @return cv::Mat
 */
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;


/**
 start stitch action

 @param flag stitch type
 */
+ (void)startStitch:(int)flag;

//stitch manager
bool read_index_weight_table(unsigned int **mapidx, char *filename, int* width, int* height,int * isOri);

bool stitch(unsigned int *mapidx, int width, int height, BYTE ** images, BYTE * resultimage);

bool d_stitch(int width, int height, BYTE ** images, BYTE * resultimage);

bool GenericLoader(const char *ptrFileName1, const char *ptrFileName2, const char *ptrFileName3, const char *ptrFileName4, BYTE ** images);

void start_stitch(int flag);

@end
