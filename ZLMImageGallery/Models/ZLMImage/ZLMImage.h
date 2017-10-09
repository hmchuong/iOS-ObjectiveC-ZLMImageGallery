//
//  ZLMImage.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface ZLMImage : NSObject

@property (strong, nonatomic) PHAsset  *asset;                                  // image asset
@property (strong, nonatomic) NSString *name;                                   // name of image
@property (nonatomic)         BOOL     isManual;                                // manual caching or not

/**
 Init with asset, name and is manual caching option

 @param asset asset of image
 @param name name of image
 @param isManual is manual caching
 @return ZLMImage
 */
- (instancetype)initWithAsset:(PHAsset *)asset name:(NSString *)name isManual:(BOOL)isManual;

/**
 Get image with specific size

 @param size size of image to get
 @return image in size
 */
- (UIImage *)getImageWithSize:(CGSize)size;

@end
