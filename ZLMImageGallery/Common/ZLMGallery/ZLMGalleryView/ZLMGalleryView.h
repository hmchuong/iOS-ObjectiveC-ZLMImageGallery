//
//  ZLMGalleryView.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLMGalleryItemNIO.h"
#import "NIMutableCollectionViewModel.h"

#define DEFAULT_NUM_OF_ITEM_PER_ROW 3
#define DEFAULT_MIN_SPACE 2
#pragma mark - Delegate

@class ZLMGalleryView;

/**
 Gallery view delegate
 */
@protocol ZLMGalleryViewDelegate<NSObject>

@optional

/**
 Did select item at index

 @param galleryView gallery view call method
 @param index index of item
 */
- (void)ZLMGalleryView: (ZLMGalleryView *)galleryView didSelectItemAtIndex:(NSUInteger)index;

@end

#pragma mark Gallery view

/**
 Gallery view
 */
@interface ZLMGalleryView : UIView<NICollectionViewModelDelegate, UICollectionViewDelegate>

@property (nonatomic)         NSUInteger                  numOfItemsPerRow;       // Number of items per row
@property (nonatomic)         NSUInteger                  minSpace;               // Min space between items
@property (weak, nonatomic)   id<ZLMGalleryViewDelegate>  delegate;               // Delegate to callback

/**
 Get item at index

 @param index index of item
 @return item at index, nil if cannot find
 */
- (ZLMGalleryItemNIO *)getItemAtIndex:(NSUInteger)index;

/**
 Set gallery items

 @param items items array
 */
- (void)setItems:(NSArray<ZLMGalleryItemNIO *> *)items;

/**
 Get item size in gallery

 @return size of item
 */
- (CGSize)getItemSize;

@end
