//
//  OpenCV.h
//  OpenCVSample_OSX
//
//  Created by Ivanna Avksentieva on 10/10/19.
//  Copyright © 2019 Ivanna Avksentieva. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OpenCV : NSObject

/// Converts a full color image to grayscale image with using OpenCV.
+ (nonnull NSImage *)cvtColorBGR2GRAY:(nonnull NSImage *)image;

@end
