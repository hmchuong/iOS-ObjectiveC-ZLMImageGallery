//
//  ZLMImageLoader.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLMImage.h"

/**
 Library access authorization status

 - ZLMLibAuthNotDetermined: User has not yet made a choice with regards to this application
 - ZLMLibAuthRestricted: This application is not authorized to access photo data
 - ZLMLibAuthDenied: User has explicitly denied this application access to photos data
 - ZLMLibAuthorized: User has authorized this application to access photos data
 */
typedef NS_ENUM( NSUInteger, ZLMLibraryAuthorizationStatus) {
    ZLMLibAuthNotDetermined,
    ZLMLibAuthRestricted,
    ZLMLibAuthDenied,
    ZLMLibAuthorized
};

/**
 Object for load image from phone's library
 */
@interface ZLMImageLoader : NSObject

+ (instancetype)sharedInstance;

- (instancetype)init NS_UNAVAILABLE;

/**
 Get images from library with completion

 @param completion completion to callback
 @param queue queue to callback
 */
- (void)getImagesFromLibraryWithCompletion:(void(^)(ZLMLibraryAuthorizationStatus grantedStatus, NSError *error, NSArray<ZLMImage *> *images))completion
                                     queue:(dispatch_queue_t)queue;

@end
