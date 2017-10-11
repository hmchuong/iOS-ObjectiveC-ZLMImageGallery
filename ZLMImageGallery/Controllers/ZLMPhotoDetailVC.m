//
//  ZLMPhotoDetailVC.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/11/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMPhotoDetailVC.h"

@interface ZLMPhotoDetailVC ()

@end

@implementation ZLMPhotoDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_pagerView registerClass:[FSPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //[_pagerView scrollToItemAtIndex:_currentIndex animated:NO];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfItemsInPagerView:(FSPagerView * _Nonnull)pagerView {
    return [_images count];
}

- (FSPagerViewCell * _Nonnull)pagerView:(FSPagerView * _Nonnull)pagerView cellForItemAtIndex:(NSInteger)index {
    
    FSPagerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"cell" atIndex:index];
    ZLMImage *image = [_images objectAtIndex:index];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = cell.imageView.frame.size;
    if (size.height == 0 || size.width == 0) {
        size = CGSizeMake(300, 300);
    }
    cell.imageView.image = [image getImageWithSize:size];
    cell.textLabel.text = [NSString stringWithFormat:@"%d/%d",index+1,[_images count]];
    return cell;
}

@end
