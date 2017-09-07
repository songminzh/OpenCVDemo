//
//  UIImage+OpenCV.m
//  OpenCVDemo
//
//  Created by Murphy Zheng on 17/8/23.
//  Copyright © 2017年 mieasy. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include <float.h>
#include <math.h>
#include <cstring>
#include <ctime>

#import "UIImage+OpenCV.h"

@implementation UIImage (OpenCV)

#pragma mark  - OpenCV Methods
- (cv::Mat)CVMat {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows,cols,CV_8UC(4)); // 8 bits per component,4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                      // Height of bitmap
                                                    8,                         // Bits per conponent
                                                    cvMat.step[0],             // Bytes per row
                                                    colorSpace,                // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);// Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)CVGrayscaleMat {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat = cv::Mat(rows,cols,CV_8SC1); // 8 bits per conponpent,1 channel
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                      // Height of bitmap
                                                    8,                         // Bits of bitmap
                                                    cvMat.step[0],             //Bytes per row
                                                    colorSpace,                // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault);// Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

//UIimage --> Gray cv::Mat
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

// cv::Mat --> UIImage
+ (UIImage *)imageWithCVMat:(const cv::Mat &)cvMat {
    return [[UIImage alloc] initWithCVMat:cvMat];
}

- (id)initWithCVMat:(const cv::Mat &)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                // Width
                                        cvMat.rows,                // Height
                                        8,                         // Bits per component
                                        8 * cvMat.elemSize(),      // Bits per pixel
                                        cvMat.step[0],             // Bytes per row
                                        colorSpace,                // Colorspace
                                        kCGImageAlphaNone |
                                        kCGBitmapByteOrderDefault, // Bitmap info flags
                                        provider,                  // CgDataProviderRef
                                        NULL,                      // Decode
                                        false,                     // Should interpolate
                                        kCGRenderingIntentDefault);// Intent
    
    self = [self initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}

#pragma mark  - C++ & Objecive-C transfer
/**
 NSString --> char *
 
 @param string NSString (Objective-C)
 @return char *         (C++)
 */
char * string2Char(NSString *string) {
    const char *charString = [string UTF8String];
    char *result = new char[strlen(charString) + 1];
    strcpy(result, charString);
    //    delete[] result;
    return result;
}


/**
 Write image to Document

 @param imageName image name
 @param img cv::Mat
 @return if complete
 */
bool writeImage2Document(const char *imageName, cv::Mat img) {
    UIImage *stitchedImage = [[UIImage alloc] initWithCVMat:img];
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imagePath = [docPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[NSString stringWithUTF8String:imageName]]];
    // 将UIImage对象转换成NSData对象
    NSData *data = UIImageJPEGRepresentation(stitchedImage, 0);
    [data writeToFile:imagePath atomically:YES];
    return true;
}

#pragma mark  - Stitch
//开始拼接
+ (void)startStitch:(int)flag {
    start_stitch(flag);
}

//读取权重表
bool read_index_weight_table(unsigned int **mapidx, char *filename,int * width,int * height,int * isOri) {
    FILE *f;
    char buf[CMV_MAX_BUF];
    
    unsigned int *mapidxo;
    
    int i, j;
    
    //Open file
    NSString * path = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:filename] ofType:nil];
    f = fopen([path cStringUsingEncoding:1],"r");
    if (f == NULL) {
        return false;
    }
    
    fgets(buf, CMV_MAX_BUF, f);
    //fscanf(f, "\n");
    fscanf(f, "%d", height);
    fscanf(f, "%d", width);
    fscanf(f, "\n");
    fgets(buf, CMV_MAX_BUF, f);
    //fscanf(f, "\n");
    fscanf(f, "%d", isOri);
    fscanf(f, "\n");
    fgets(buf, CMV_MAX_BUF, f);
    mapidxo = new unsigned int[(*width) * (*height) * 4];
    memset(mapidxo, 0, sizeof(unsigned int) * (*width) * (*height) * 4);
    int mpidx = 0;
    for (i = 0; i < (*height); ++i)
    {
        for (j = 0; j < (*width); ++j)
        {
            fscanf(f, "%d", mapidxo + mpidx );
            fscanf(f, " %d", mapidxo + mpidx + 1);
            fscanf(f, " %d", mapidxo + mpidx + 2);
            fscanf(f, " %d", mapidxo + mpidx + 3);
            mpidx += 4;
        }
        fscanf(f, "\n");
    }
    
    *mapidx = mapidxo;
    //Close file
    fclose(f);
    
    return true;
}

//核心拼接代码
bool stitch(unsigned int *mapidx, int width, int height, BYTE ** images, BYTE * resultimage) {
    int total_pixel = width * height;
    unsigned int  pindex = 0;
    unsigned int  iindex = 0;
    unsigned int  im1 = 0;
    unsigned int  im2 = 0;
    unsigned int  im3 = 0;
    unsigned int  index1 = 0;
    unsigned int  index2 = 0;
    unsigned int  index3 = 0;
    unsigned int  weight1 = 0;
    unsigned int  weight2 = 0;
    unsigned int  weight3 = 0;
    
    for (int i = 0; i < total_pixel; ++i)
    {
        pindex = i << 2;
        iindex = (i << 1) + i;
        switch (mapidx[pindex] & IMAGE_NUM_MASK)
        {
            case 1:
                im1 = (mapidx[pindex] & IMAGE_INDEX1_MASK) >> 2;
                index1 = ((mapidx[pindex + 1] & INDEX_MASK) << 1) + (mapidx[pindex + 1] & INDEX_MASK); //index * 3;
                memcpy(resultimage + iindex, images[im1] + index1, sizeof(BYTE) * 3);
                break;
            case 2:
                im1 = (mapidx[pindex] & IMAGE_INDEX1_MASK) >> 2;
                index1 = ((mapidx[pindex + 1] & INDEX_MASK) << 1) + (mapidx[pindex + 1] & INDEX_MASK);
                weight1 = (mapidx[pindex + 1] & WEIGHT_MASK) >> 21;
                im2 = (mapidx[pindex] & IMAGE_INDEX2_MASK) >> 4;
                index2 = ((mapidx[pindex + 2] & INDEX_MASK) << 1) + (mapidx[pindex + 2] & INDEX_MASK);
                weight2 = (mapidx[pindex + 2] & WEIGHT_MASK) >> 21;
                resultimage[iindex] = (images[im1][index1] * weight1 + images[im2][index2] * weight2) >> 10;
                resultimage[iindex + 1] = (images[im1][index1 + 1] * weight1 + images[im2][index2 + 1] * weight2) >> 10;
                resultimage[iindex + 2] = (images[im1][index1 + 2] * weight1 + images[im2][index2 + 2] * weight2) >> 10;
                break;
            case 3:
                im1 = (mapidx[pindex] & IMAGE_INDEX1_MASK) >> 2;
                index1 = ((mapidx[pindex + 1] & INDEX_MASK) << 1) + (mapidx[pindex + 1] & INDEX_MASK);
                weight1 = (mapidx[pindex + 1] & WEIGHT_MASK) >> 21;
                im2 = (mapidx[pindex] & IMAGE_INDEX2_MASK) >> 4;
                index2 = ((mapidx[pindex + 2] & INDEX_MASK) << 1) + (mapidx[pindex + 2] & INDEX_MASK);
                weight2 = (mapidx[pindex + 2] & WEIGHT_MASK) >> 21;
                im3 = (mapidx[pindex] & IMAGE_INDEX3_MASK) >> 6;
                index3 = ((mapidx[pindex + 3] & INDEX_MASK) << 1) + (mapidx[pindex + 3] & INDEX_MASK);
                weight3 = (mapidx[pindex + 3] & WEIGHT_MASK) >> 21;
                resultimage[iindex] = (images[im1][index1] * weight1 + images[im2][index2] * weight2 + images[im3][index3] * weight3) >> 10;
                resultimage[iindex + 1] = (images[im1][index1 + 1] * weight1 + images[im2][index2 + 1] * weight2 + images[im3][index3 + 1] * weight3) >> 10;
                resultimage[iindex + 2] = (images[im1][index1 + 2] * weight1 + images[im2][index2 + 2] * weight2 + images[im3][index3 + 2] * weight3) >> 10;
                break;
                
            default:
                break;
        }
    }
    return true;
    
}

bool d_stitch(int width, int height, BYTE ** images, BYTE * resultimage) {
    //int total_pixel = width * height;
    
    int h_width = width / 2;
    int h_height = height / 2;
    int hi = 0;
    for (int h = 0; h < h_height; ++h)
    {
        BYTE *scanline = resultimage + h * width * 3 ;
        memcpy(scanline, images[0] + h * h_width * 3, sizeof(BYTE) * h_width * 3);
    }
    
    for (int h = 0; h < h_height; ++h)
    {
        
        BYTE *scanline = resultimage + h * width * 3 + h_width * 3;
        memcpy(scanline, images[1] + h * h_width * 3, sizeof(BYTE) * h_width * 3);
    }
    for (int h = h_height; h < height; ++h)
    {
        BYTE *scanline = resultimage + h * width * 3;
        memcpy(scanline, images[2] + hi * h_width * 3, sizeof(BYTE) * h_width * 3);
        ++hi;
    }
    hi = 0;
    for (int h = h_height; h < height; ++h)
    {
        BYTE *scanline = resultimage + h * width * 3 + h_width * 3;
        memcpy(scanline, images[3] + hi * h_width * 3, sizeof(BYTE) * h_width * 3);
        ++hi;
    }
    
    return true;
}

void start_stitch(int flag) {
    unsigned int *mapidx;
    int width = 0;
    int height = 0;
    
    int isOri = 0;
    printf("start stitch");
    
    char oriPath1[100];
    char oriPath2[100];
    char oriPath3[100];
    char oriPath4[100];
    time_t start, finished;
    float ellapsed_time;
    
    BYTE **images;
    images = new BYTE*[4];
    for (int i = 0; i < 4; i++)
    {
        images[i] = new BYTE[3 * ORI_HEIGHT * ORI_WIDTH];
        memset(images[i], '\0', sizeof(BYTE) * 3 * ORI_HEIGHT * ORI_WIDTH);
    }
    
    printf("Load map table.\n");
    
    char *map1 = string2Char(@"map.dat");
    char *map2 = string2Char(@"map2.dat");
    
    if (flag == 0)
        read_index_weight_table(&mapidx, map1, &width, &height, &isOri); //读取影射关系表 未校正
    else
        read_index_weight_table(&mapidx, map2, &width, &height, &isOri); //读取影射关系表 校正后
    
    if (isOri)
    {
        strcpy(oriPath1, "87.bmp");
        strcpy(oriPath2, "88.bmp");
        strcpy(oriPath3, "89.bmp");
        strcpy(oriPath4, "90.bmp");
    }
    else
    {
        strcpy(oriPath1, "87-rect.jpg");
        strcpy(oriPath2, "88-rect.jpg");
        strcpy(oriPath3, "89-rect.jpg");
        strcpy(oriPath4, "90-rect.jpg");
        
    }
    printf("Load orignal images.\n");
    
    GenericLoader(oriPath1, oriPath2, oriPath3, oriPath4, images);  //读取原始图像
    
    BYTE * resultimage;
    resultimage = new BYTE[3 * height * width];
    memset(resultimage, '\0', sizeof(BYTE) * 3 * height * width);
    
    printf("Stitch images.\n");
    start = clock();
    stitch(mapidx, width, height, images, resultimage); //拼接图像
    
    finished = clock();
    ellapsed_time = (float)(finished - start) / CLOCKS_PER_SEC;
    printf("Ellapse  %f seconds\n", ellapsed_time);
    if (flag == 0)
        saveresult("stitch2.jpg", width, height, resultimage);
    else
        saveresult("stitch.jpg", width, height, resultimage);
    
    printf("end");
    delete[] mapidx;
    for (int i = 0; i < 4; i++)
    {
        delete[] images[i];
    }
    delete[] resultimage;
    delete[] images;
}

//读取图片数据
bool GenericLoader(const char *ptrFileName1, const char *ptrFileName2, const char *ptrFileName3, const char *ptrFileName4, BYTE ** images) {
    cv::Mat image0;
    cv::Mat image1;
    cv::Mat image2;
    cv::Mat image3;
    NSString *imagePath1 = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:ptrFileName1] ofType:nil];
    NSString *imagePath2 = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:ptrFileName2] ofType:nil];
    NSString *imagePath3 = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:ptrFileName3] ofType:nil];
    NSString *imagePath4 = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:ptrFileName4] ofType:nil];
    image0 = cv::imread([imagePath1 UTF8String], CV_LOAD_IMAGE_COLOR);
    image1 = cv::imread([imagePath2 UTF8String], CV_LOAD_IMAGE_COLOR);
    image2 = cv::imread([imagePath3 UTF8String], CV_LOAD_IMAGE_COLOR);
    image3 = cv::imread([imagePath4 UTF8String], CV_LOAD_IMAGE_COLOR);
    
    writeImage2Document(ptrFileName1,image0);
    writeImage2Document(ptrFileName2,image1);
    writeImage2Document(ptrFileName3,image2);
    writeImage2Document(ptrFileName4,image3);
    
    ScanImageAndReduceC(image0, images[0]);
    ScanImageAndReduceC(image1, images[1]);
    ScanImageAndReduceC(image2, images[2]);
    ScanImageAndReduceC(image3, images[3]);
    
    return false;
}

cv::Mat& ScanImageAndReduceC(cv::Mat& I,  uchar* const table) {
    // accept only char type matrices
    CV_Assert(I.depth() != sizeof(uchar));
    int channels = I.channels();
    int nRows = I.rows;
    int nCols = I.cols* channels;
    if (I.isContinuous())
    {
        nCols *= nRows;
        nRows = 1;
    }
    int i, j;
    uchar* p;
    for (i = 0; i < nRows; ++i)
    {
        p = I.ptr<uchar>(i);
        for (j = 0; j < nCols; ++j)
        {
            
            table[j] = p[j];
        }
    }
    return I;
}

//保存拼接结果
bool saveresult(const char *ptrFileName, int width, int height, BYTE * resultimage) {
    cv::Mat img = cv::Mat(height, width, CV_8UC3, resultimage, 0);
    bool isSaved = writeImage2Document(ptrFileName,img);
    if (isSaved) {
        printf("Stitch success!\n");
    }else {
        printf("Some thing wrong, can not be sticthed!\n");
    }
    return isSaved;
}

@end
