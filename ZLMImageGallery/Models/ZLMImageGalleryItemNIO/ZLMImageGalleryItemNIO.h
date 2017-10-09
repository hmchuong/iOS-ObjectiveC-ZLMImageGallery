//
//  ZLMImageGalleryItemNIO.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZLMGalleryItemNIO.h"
#import "ZLMImage.h"

@interface ZLMImageGalleryItemNIO : ZLMGalleryItemNIO

@property (strong, nonatomic) ZLMImage *image;
@property (nonatomic)         CGSize    size;

/**
 Init with image and target size

 @param image image wrapper
 @param size target size
 @return Gallery item
 */
- (instancetype)initWithImage:(ZLMImage *)image
                         size:(CGSize)size;

@end
