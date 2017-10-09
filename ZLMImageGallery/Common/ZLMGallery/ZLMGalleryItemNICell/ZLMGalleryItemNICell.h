//
//  ZLMGalleryItemNICell.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NimbusCollections.h"

/**
 Nimbus collection cell for gallery item
 */
@interface ZLMGalleryItemNICell : UICollectionViewCell<NICollectionViewCell>

@property (strong, nonatomic) UIImageView *thumbnail;           // Thumbnail of item

@end
