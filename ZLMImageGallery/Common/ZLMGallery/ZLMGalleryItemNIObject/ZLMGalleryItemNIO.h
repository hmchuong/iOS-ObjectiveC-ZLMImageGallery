//
//  ZLMGalleryItemNIO.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NimbusCollections.h"

/**
 Gallery item object for collection view
 */
@interface ZLMGalleryItemNIO : NSObject<NICollectionViewCellObject>

 /**
  Get thumbnail image of gallery item

  @return thumbnail image
  */
 - (UIImage *)getThumbnailImage;

@end
