//
//  ZLMImageLoader.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMImageLoader.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation ZLMImageLoader

#pragma mark - Constructors

- (instancetype)init {
    
    self = [super init];
    
    return self;
}

+ (instancetype)sharedInstance {
    
    static ZLMImageLoader *sharedImageLoader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageLoader = [[self alloc] init];
    });
    return sharedImageLoader;
}

#pragma mark - Public methods

- (void)getImagesFromLibraryWithCompletion:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion queue:(dispatch_queue_t)queue{
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self loadImagesWithALAssets:completion queue:queue];
    } else {
        [self loadImagesWithPHPhoto:completion queue:queue];
    }
}

#pragma mark - Utilities

- (void)getPHPhotoAuthStatus:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion
                       queue:(dispatch_queue_t)queue {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        ZLMLibraryAuthorizationStatus authStatus;
        switch (status) {
            case PHAuthorizationStatusAuthorized:
                [self fetchPHPhotos:completion queue:queue];
                return;
            case PHAuthorizationStatusDenied:
                authStatus = ZLMLibAuthDenied;
            case PHAuthorizationStatusRestricted:
                authStatus = ZLMLibAuthRestricted;
            case PHAuthorizationStatusNotDetermined:
                authStatus = ZLMLibAuthNotDetermined;
        }
        dispatch_async(queue, ^{
            completion(authStatus, nil, nil);
        });
        
    }];
}

- (void)fetchPHPhotos:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion
              queue:(dispatch_queue_t)queue {
    
    // Fetch photos
    NSMutableArray<ZLMImage *> *images = [[NSMutableArray alloc] init];
    NSMutableArray<PHAsset *> *assets = [[NSMutableArray alloc] init];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    
    for (PHAsset *asset in result) {
        [images addObject:[[ZLMImage alloc] initWithAsset:asset name:nil isManual:false]];
        [assets addObject:asset];
    }
    
    PHCachingImageManager *imageManager = (PHCachingImageManager *)[PHCachingImageManager defaultManager];
    [imageManager startCachingImagesForAssets:assets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil];
    
    dispatch_async(queue, ^{
        completion(ZLMLibAuthorized, nil, images);
    });
}

/**
 Load images with Photos framework (iOS >= 8.0)

 @param completion completion to callback
 @param queue queue to callback
 */
- (void)loadImagesWithPHPhoto:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion
                        queue:(dispatch_queue_t)queue {
    
    if (queue == nil) {
        queue = dispatch_get_main_queue();
    }
    
    // Authorization
    [self getPHPhotoAuthStatus:completion queue:queue];
}

/**
 Get authorization status of ALAsset`

 @return authorization status
 */
- (ZLMLibraryAuthorizationStatus)getALAuthStatus {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusDenied:
            return ZLMLibAuthDenied;
        case ALAuthorizationStatusAuthorized:
            return ZLMLibAuthorized;
        case ALAuthorizationStatusRestricted:
            return ZLMLibAuthRestricted;
        case ALAuthorizationStatusNotDetermined:
            return ZLMLibAuthNotDetermined;
    }
}

/**
 Load images with ALAssets

 @param completion completion to callback
 @param queue queue to callback
 */
- (void)loadImagesWithALAssets:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion
                         queue:(dispatch_queue_t)queue {
    
    
    if (queue == nil) {
        queue = dispatch_get_main_queue();
    }
    
    // Authorization
    ZLMLibraryAuthorizationStatus gratedStatus = [self getALAuthStatus];
    
    if (gratedStatus != ZLMLibAuthorized) {
        dispatch_async(queue, ^{
            completion(gratedStatus, nil, nil);
        });
        return;
    }
    
    // Fetch photos
}

@end
