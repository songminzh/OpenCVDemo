# OpenCVDemo

![OpenCV for iOS](http://upload-images.jianshu.io/upload_images/2251123-b1539f93bb74b474.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 关于OpenCV

------

## 简介

> OpenCV (Open Source Computer Vision Library)是一个在BSD许可下发布的开源库，因此它是免费提供给学术和商业用途。有C++、C、Python和Java接口，支持Windows、Linux、MacOS、iOS和Android等系统。OpenCV是为计算效率而设计的，而且密切关注实时应用程序的发展和支持。该库用优化的C/C++编写,可以应用于多核处理。在启用OpenCL的基础上，它可以利用底层的异构计算平台的硬件加速。

                                                                                        ——opencv.org

## OpenCV的模块

从[官方文档]([http://docs.opencv.org/2.4/modules/core/doc/intro.html)中我们可以看到其包含模块以及对iOS的支持情况。

>* core：简洁的核心模块，定义了基本的数据结构，包括稠密多维数组 Mat 和其他模块需要的基本函数。

>* imgproc：图像处理模块，包括线性和非线性图像滤波、几何图像转换 (缩放、仿射与透视变换、一般性基于表的重映射)、颜色空间转换、直方图等等。

 >* video：视频分析模块，包括运动估计、背景消除、物体跟踪算法。

>* calib3d：包括基本的多视角几何算法、单体和立体相机的标定、对象姿态估计、双目立体匹配算法和元素的三维重建。

>* features2d：包含了显著特征检测算法、描述算子和算子匹配算法。

>* objdetect：物体检测和一些预定义的物体的检测 (如人脸、眼睛、杯子、人、汽车等)。

>* ml：多种机器学习算法，如 K 均值、支持向量机和神经网络。

>* highgui：一个简单易用的接口，提供视频捕捉、图像和视频编码等功能，还有简单的 UI 接口 (iOS 上可用的仅是其一个子集)。

>* gpu：OpenCV 中不同模块的 GPU 加速算法 (iOS 上不可用)。

>* ocl：使用 OpenCL 实现的通用算法 (iOS 上不可用)。

>* 一些其它辅助模块，如 Python 绑定和用户贡献的算法。





## 我们可以利用OpenCV在iOS上做什么

基于OpenCV，iOS应用程序可以实现很多有趣的功能，也可以把很多复杂的工作简单化。一般可用于：

  * 对图片进行灰度处理（官方示例）

  * 人脸识别，即特征跟踪（官方示例）

  * 训练图片特征库（可用于模式识别）

  * 提取特定图像内容（根据需求还原有用图像信息）

…… 



# 导入OpenCV

------

opencv目前分为两个版本系列：opencv2.4.x和opencv3.x。

导入项目的两种方式：

## 1.从官网下载框架，引入工程。

1. 前往[OpenCV官网](http://opencv.org)或[OpenCV中文官网](http://opencv.org.cn)下载相关iOS版本framework文件，从项目引入，

1. 导入OpenCV依赖库

  * libc++.tbd

  * AVFoundation.framework

  * CoreImage.framework

  * QuartzCore.framework

  * Accelerate.framework

  * CoreVideo.framework

  * CoreMedia.framework

  * AssetsLibrary.framework



1. 引入相关头文件

```

#import <opencv2/opencv.hpp>



#import <opencv2/imgproc/types_c.h>



#import <opencv2/imgcodecs/ios.h>



#import <opencv2/highgui/highgui_c.h>



```

**注：使用OpenCV的类必须支持C++的编译环境，把.m文件改为.mm即可。**

## 2.使用CocoaPods安装。

很简单。

```

pod 'OpenCV'

```



# OpenCV的简单使用

------

处理图片可以创建一个UIImage的分类，OpenCV图像处理的相关代码都可以在这个类中实现。

代码可见[笔者Github项目地址](https://github.com/fusugz/OpenCVDemo)

## 图像灰度处理

1.在.h文件中声明两个类

```

@property (nonatomic, readonly) cv::Mat CVMat;



@property (nonatomic, readonly) cv::Mat CVGrayscaleMat;

```

2.声明Mat与UIImage互相转换以及灰度处理并返回UIImage对象的外部方法

```

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

```



3.在.m中实现相关方法

生成cv::Mat对象

```

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

```

生成灰度cv::Mat对象

```

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

```



cv::Mat --> UIImage

```

+ (UIImage *)imageWithCVMat:(const cv::Mat &)cvMat {



    return [[UIImage alloc] initWithCVMat:cvMat];



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



```



UIimage --> Gray cv::Mat

```

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

```



4.在控制器中调用UIImage+OpenCV相关代码，实现图片灰度处理



```



UIImage *image = [UIImage imageNamed:@"icon.jpg"];



cv::Mat inputMat = [UIImage cvMatFromUIImage:image];



cv::Mat greyMat;



cv::cvtColor(inputMat, greyMat, CV_BGR2GRAY);



//cv::Mat greyMat = [UIImage cvMatGrayFromUIImage:image];



UIImage *greyImage = [UIImage imageWithCVMat:greyMat];



self.imageView.image = greyImage;

```



5.效果

![原图](http://upload-images.jianshu.io/upload_images/2251123-cf81da71909a46a0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![处理后](http://upload-images.jianshu.io/upload_images/2251123-693a4d64aaea3539.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)





## 人脸识别

关于人脸识别的实现，可以参考[基于OpenCV的人脸识别]([https://objccn.io/issue-21-9/)。这是ObjC中国上一篇译文，作者是国外大牛，这片博客写得非常详尽。

我的Demo中不含有拍照部分，直接对一张图片中的人脸进行识别，其实现如下：

1.创建一个Objective-C++的类FaceRecognition（即把.m文件.mm文件，支持Objective-C与C++混编）

2.引入头文件：

```



#import <opencv2/opencv.hpp>



#import <opencv2/imgproc/types_c.h>



#import <opencv2/imgcodecs/ios.h>



#import "UIImage+OpenCV.h"

```

3.对图片进行处理转化

```



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

```

4.读取图片中人脸的相关数据并存储

```

+ (NSArray*)facePointDetectForImage:(UIImage*)image{



    static cv::CascadeClassifier faceDetector;



    static dispatch_once_t onceToken;



    dispatch_once(&onceToken, ^{



        // 添加xml文件



        NSString* cascadePath = [[NSBundle mainBundle]



                                 pathForResource:@"haarcascade_frontalface_alt2"



                                 ofType:@"xml"];



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

```

5.检测人脸并在图片上人脸部分添加红色矩形线框以标识

```

+ (UIImage*)faceDetectForImage:(UIImage*)image {



    static cv::CascadeClassifier faceDetector;



    static dispatch_once_t onceToken;



    dispatch_once(&onceToken, ^{



        



        NSString* cascadePath = [[NSBundle mainBundle]



                                 pathForResource:@"haarcascade_frontalface_alt"



                                 ofType:@"xml"];



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

```

6.运行效果

![Face Recognition](http://upload-images.jianshu.io/upload_images/2251123-c1e60be522f96708.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



# Objective-C与C++混编

------

很多地方需要用到Objective-C与C++混编，来解决一些对象的传递转换问题。

## 字符串的转换

在C++中，字符串对象为`char *`,而在Objective-C中字符串对象为`NSString`,在编程中常常需要在二者之间互相转换。

1.`NSString`转换为`char *`

```



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



```



2.`char *`转换为`NSString`

```

NSString *OCString = [NSString stringWithUTF8String:cppString];

```



## 储存cv::Mat图片对象

```



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

```