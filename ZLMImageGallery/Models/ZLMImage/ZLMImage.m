//
//  ZLMImage.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMImage.h"
#import "ZLMImageCache.h"

@interface ZLMImage()

@property (strong, nonatomic) PHImageRequestOptions * requestOptions;

@end

@implementation ZLMImage

- (instancetype)initWithAsset:(PHAsset *)asset name:(NSString *)name isManual:(BOOL)isManual {
    
    self = [super init];
    
    self.asset = asset;
    self.name = name;
    self.isManual = isManual;
    
    return self;
}

#pragma mark - Public methods

- (UIImage *)getImageWithSize:(CGSize)size {
    
    if (_isManual) {
        
        // Manual get caching image
        return [[ZLMImageCache sharedInstance] imageFromKey:_name
                                                   withSize:size];
    } else {
        
        // Use PHCachingImageManager
        return [self PHCachingImageWithSize:size];
    }
}

#pragma mark - Utilities

/**
 Get caching image with size

 @param size size of image
 @return cached image
 */
- (UIImage *)PHCachingImageWithSize:(CGSize)size {
    
    if (_requestOptions == nil) {
        _requestOptions = [[PHImageRequestOptions alloc] init];
        _requestOptions.synchronous = true;
    }
    
    UIImage *__block image;
    [[PHCachingImageManager defaultManager] requestImageForAsset:_asset
                                                      targetSize:size
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:_requestOptions
                                                   resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                       image = result;
                                                   }];
    return image;
}

@end
