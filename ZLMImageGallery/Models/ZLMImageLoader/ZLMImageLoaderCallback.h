//
//  ZLMImageLoaderCallback.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/11/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLMImageLoader.h"

@interface ZLMImageLoaderCallback : NSObject

@property (copy,nonatomic) void(^completion)(ZLMLibraryAuthorizationStatus grantedStatus, NSError *error, NSArray<ZLMImage *> *images);
@property (nonatomic) dispatch_queue_t queue;

@end
