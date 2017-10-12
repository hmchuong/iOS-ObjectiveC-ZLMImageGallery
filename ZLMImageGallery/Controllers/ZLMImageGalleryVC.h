//
//  ZLMImageGalleryVC.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/5/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLMGalleryView.h"
@import FSPagerView;

@interface ZLMImageGalleryVC: UIViewController<ZLMGalleryViewDelegate, FSPagerViewDataSource, FSPagerViewDelegate>

@end

