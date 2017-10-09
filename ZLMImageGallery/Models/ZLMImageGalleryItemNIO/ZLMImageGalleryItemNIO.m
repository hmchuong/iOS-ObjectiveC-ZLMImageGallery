//
//  ZLMImageGalleryItemNIO.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMImageGalleryItemNIO.h"

@implementation ZLMImageGalleryItemNIO

- (instancetype)initWithImage:(ZLMImage *)image size:(CGSize)size {
    
    self = [super init];
    _image = image;
    _size = size;
    return self;
}

- (UIImage *)getThumbnailImage {
    return [_image getImageWithSize:_size];
}

@end
