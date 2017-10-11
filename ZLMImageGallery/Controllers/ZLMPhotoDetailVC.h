//
//  ZLMPhotoDetailVC.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/11/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ZLMImage.h"
@import FSPagerView;

@interface ZLMPhotoDetailVC : UIViewController<FSPagerViewDelegate, FSPagerViewDataSource>

@property (weak, nonatomic) IBOutlet FSPagerView *pagerView;
@property (weak, nonatomic) NSArray *images;
@property (nonatomic) NSUInteger currentIndex;

@end
