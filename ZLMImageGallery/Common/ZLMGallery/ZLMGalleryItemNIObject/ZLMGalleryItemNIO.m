//
//  ZLMGalleryItemNIO.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMGalleryItemNIO.h"
#import "ZLMGalleryItemNICell.h"

@implementation ZLMGalleryItemNIO

- (UIImage *)getThumbnailImage {
    NSString *descrip = [NSString stringWithFormat:@"child implementation for method:%@ :  %@",NSStringFromSelector(_cmd),  NSStringFromClass([self class])];
    NSAssert(NO, descrip);
    
    return [[UIImage alloc] init];
}

- (Class)collectionViewCellClass {
    return [ZLMGalleryItemNICell class];
}

@end
