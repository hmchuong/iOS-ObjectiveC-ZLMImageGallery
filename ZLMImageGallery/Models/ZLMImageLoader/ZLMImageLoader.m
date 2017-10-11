//
//  ZLMImageLoader.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMImageLoader.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLMImageCache.h"
#import "ZLMThreadSafeMutableArray.h"
#import "ZLMImageLoaderCallback.h"

@interface ZLMImageLoader()

@property (nonatomic)           ZLMLibraryAuthorizationStatus   authStatus;
@property (strong, nonatomic)   ZLMThreadSafeMutableArray       *observerCallbacks;
@property (nonatomic)           BOOL                            isChanged;
@property (strong, nonatomic)   NSArray<ZLMImage*>              *fetchedImages;

@end

@implementation ZLMImageLoader

#pragma mark - Constructors

- (instancetype)init {
    
    self = [super init];
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [self ALAuthStatus];
    } else {
        [self PHPhotoAuthStatus];
    }
    _isChanged = YES;
    _observerCallbacks = [[ZLMThreadSafeMutableArray alloc] init];
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

- (void)getImagesFromLibraryWithCompletion:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion queue:(dispatch_queue_t)queue changedObserver:(BOOL)isChangedObserver {
    
    if (queue == nil) {
        queue = dispatch_get_main_queue();
    }
    
    if (isChangedObserver) {
        ZLMImageLoaderCallback *callback = [[ZLMImageLoaderCallback alloc] init];
        callback.completion = completion;
        callback.queue = queue;
        [_observerCallbacks addObject:callback];
    }
    
    // Authorization
    if (_authStatus != ZLMLibAuthorized) {
        dispatch_async(queue, ^{
            completion(_authStatus, nil, nil);
        });
        return;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [self loadImagesWithALAssets:completion queue:queue];
    } else {
        [self loadImagesWithPHPhoto:completion queue:queue];
    }
}
- (void)requestPermission:(void (^)(void))completion {
    
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        [self requestALAPermission:completion];
    } else {
        [self requestPHPermission:completion];
    }
}

#pragma mark - OnChanged

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    
    NSArray *callbacks = [_observerCallbacks toNSArray];
    _isChanged = YES;
    for (ZLMImageLoaderCallback *callback in callbacks) {
        [self loadImagesWithPHPhoto:callback.completion queue:callback.queue];
    }
}

/**
 Callback when ALAPhotoLibrary changed
 */
- (void)ALAPhotoLibraryChanged {
    
    NSArray *callbacks = [_observerCallbacks toNSArray];
    _isChanged = YES;
    for (ZLMImageLoaderCallback *callback in callbacks) {
        [self loadImagesWithALAssets:callback.completion queue:callback.queue];
    }
}

#pragma mark - Utilities

/**
 Request permission from PHPhoto

 @param completion completion called when request done
 */
- (void)requestPHPermission:(void(^)(void))completion{
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        [self PHPhotoAuthStatus];
        completion();
    }];
}

/**
 Request permission form ALAsset
 */
- (void)requestALAPermission:(void(^)(void))completion {
    
    void(^callBlock)(BOOL granted, NSError *error) = ^(BOOL granted, NSError *error) {
        [self ALAuthStatus];
        completion();
    };
    
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        callBlock(YES, nil);
        return;
    }
    
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        /// avoid duplication call
        if (group || !*stop) {
            *stop = YES;
            callBlock(YES, nil);
        }
    } failureBlock:^(NSError *error) {
        callBlock(NO, error);
    }];
}

/**
 Get PHPhoto Authorization status
 */
- (void)PHPhotoAuthStatus {
    
    id __weak weakSelf = self;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            _authStatus = ZLMLibAuthorized;
            [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:weakSelf];
            break;
        case PHAuthorizationStatusDenied:
            _authStatus = ZLMLibAuthDenied;
            break;
        case PHAuthorizationStatusRestricted:
            _authStatus = ZLMLibAuthRestricted;
            break;
        case PHAuthorizationStatusNotDetermined:
            _authStatus = ZLMLibAuthNotDetermined;
            break;
    }
}

/**
 Get authorization status of ALAsset
 */
- (void)ALAuthStatus {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    switch (status) {
        case ALAuthorizationStatusDenied:
            _authStatus = ZLMLibAuthDenied;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(ALAPhotoLibraryChanged)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:nil];
            break;
        case ALAuthorizationStatusAuthorized:
            _authStatus = ZLMLibAuthorized;
            break;
        case ALAuthorizationStatusRestricted:
            _authStatus = ZLMLibAuthRestricted;
            break;
        case ALAuthorizationStatusNotDetermined:
            _authStatus = ZLMLibAuthNotDetermined;
            break;
    }
}

/**
 Load images with Photos framework (iOS >= 9.0)

 @param completion completion to callback
 @param queue queue to callback
 */
- (void)loadImagesWithPHPhoto:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion
                        queue:(dispatch_queue_t)queue{
    
    if (!_isChanged) {
        dispatch_async(queue, ^{
            completion(_authStatus, nil, _fetchedImages);
        });
    }
    _isChanged = NO;
    // Fetch photos
    NSMutableArray<ZLMImage *> *images = [[NSMutableArray alloc] init];
    NSMutableArray<PHAsset *> *assets = [[NSMutableArray alloc] init];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:nil];
    
    for (PHAsset *asset in result) {
        [images addObject:[[ZLMImage alloc] initWithAsset:asset name:nil isManual:false]];
        [assets addObject:asset];
    }
    
    PHCachingImageManager *imageManager = (PHCachingImageManager *)[PHCachingImageManager defaultManager];
    
    // Start caching image
    [imageManager startCachingImagesForAssets:assets targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil];
    
    _fetchedImages = images;
    
    // Callback
    dispatch_async(queue, ^{
        completion(_authStatus, nil, _fetchedImages);
    });
}

/**
 Load images with ALAssets

 @param completion completion to callback
 @param queue queue to callback
 */
- (void)loadImagesWithALAssets:(void (^)(ZLMLibraryAuthorizationStatus, NSError *, NSArray<ZLMImage *> *))completion
                         queue:(dispatch_queue_t)queue{
    
    if (!_isChanged) {
        dispatch_async(queue, ^{
            completion(_authStatus, nil, _fetchedImages);
        });
    }
    _isChanged = NO;
    
    // Fetch photos
    NSMutableArray<ZLMImage *> *imageArray=[[NSMutableArray alloc] init];
    NSUInteger __block count = 0;
    BOOL __block isDone = NO;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        
        if(result != nil && !isDone) {
            
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                
                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                
                [library assetForURL:url
                         resultBlock:^(ALAsset *asset) {
                             
                             // Get image
                             UIImage *image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
                             
                             NSString *identifier = [[asset defaultRepresentation] filename];
                             // Store image to cache
                             [[ZLMImageCache sharedInstance] storeImage:image withKey:identifier];
                             
                             // Add to array
                             [imageArray addObject: [[ZLMImage alloc] initWithAsset:nil name:identifier isManual:YES]];
                             
                             // Add all object
                             if ([imageArray count] == count)
                             {
                                 _fetchedImages = imageArray;
                                 // Callback
                                 dispatch_async(queue, ^{
                                     completion(_authStatus, nil, _fetchedImages);
                                 });
                                 isDone = YES;
                             }
                         }
                        failureBlock:^(NSError *error){
                            
                            // Callback
                            dispatch_async(queue, ^{
                                completion(_authStatus, error, imageArray);
                            });
                            isDone = YES;
                        } ];
                
            }
        }
    };
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            count=[group numberOfAssets];
        }
    };
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {
                             dispatch_async(queue, ^{
                                 completion(_authStatus, error, imageArray);
                             });
                         }];
}

@end
