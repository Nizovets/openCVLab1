//
//  OpenCV.m
//  OpenCVSample_OSX
//
//  Created by Ivanna Avksentieva on 10/10/19.
//  Copyright © 2019 Ivanna Avksentieva. All rights reserved.
//

// Put OpenCV include files at the top. Otherwise an error happens.
#import <vector>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc.hpp>

#import <Foundation/Foundation.h>
#import "OpenCV.h"

/// Converts an NSImage to Mat.
static void NSImageToMat(NSImage *image, cv::Mat &mat) {
	
	// Create a pixel buffer.
	NSBitmapImageRep *bitmapImageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
	NSInteger width = [bitmapImageRep pixelsWide];
	NSInteger height = [bitmapImageRep pixelsHigh];
	CGImageRef imageRef = [bitmapImageRep CGImage];
	cv::Mat mat8uc4 = cv::Mat((int)height, (int)width, CV_8UC4);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef contextRef = CGBitmapContextCreate(mat8uc4.data, mat8uc4.cols, mat8uc4.rows, 8, mat8uc4.step, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	// Draw all pixels to the buffer.
	cv::Mat mat8uc3 = cv::Mat((int)width, (int)height, CV_8UC3);
	cv::cvtColor(mat8uc4, mat8uc3, cv::COLOR_RGBA2BGR);
	
	mat = mat8uc3;
}

/// Converts a Mat to NSImage.
static NSImage *MatToNSImage(cv::Mat &mat) {
	
	// Create a pixel buffer.
	assert(mat.elemSize() == 1 || mat.elemSize() == 3);
	cv::Mat matrgb;
	if (mat.elemSize() == 1) {
		cv::cvtColor(mat, matrgb, cv::COLOR_GRAY2RGB);
	} else if (mat.elemSize() == 3) {
		cv::cvtColor(mat, matrgb, cv::COLOR_BGR2RGB);
	}
	
	// Change a image format.
	NSData *data = [NSData dataWithBytes:matrgb.data length:(matrgb.elemSize() * matrgb.total())];
	CGColorSpaceRef colorSpace;
	if (matrgb.elemSize() == 1) {
		colorSpace = CGColorSpaceCreateDeviceGray();
	} else {
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	CGImageRef imageRef = CGImageCreate(matrgb.cols, matrgb.rows, 8, 8 * matrgb.elemSize(), matrgb.step.p[0], colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
	NSImage *image = [[NSImage alloc]init];
	[image addRepresentation:bitmapImageRep];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	
	return image;
}

@implementation OpenCV

+ (nonnull NSImage *)cvtColorBGR2GRAY:(nonnull NSImage *)image {
    
	cv::Mat bgrMat;
	NSImageToMat(image, bgrMat);
	cv::Mat grayMat;
    cv::Mat finalMat;
    
    cv::cvtColor(bgrMat, grayMat, cv::COLOR_BGR2GRAY);
    NSImage *grayImage = MatToNSImage(grayMat);
    NSImageToMat(grayImage, finalMat);
    
    cv::line(finalMat, cv::Point(0, 0), cv::Point(finalMat.cols, finalMat.rows), cv::Scalar(255, 0, 0, 1), 5, -1);
    cv::rectangle(finalMat, cv::Point(finalMat.cols, 0), cv::Point(finalMat.cols - 200, 200), cv::Scalar(0, 0, 255, 1), 5, -1);
	
    NSImage *finalImage = MatToNSImage(finalMat);
	
    return finalImage;
}

@end
