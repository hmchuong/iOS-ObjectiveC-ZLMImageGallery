//
//  ZLMImageGalleryVC.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/5/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMImageGalleryVC.h"
#import "ZLMGalleryView.h"
#import "ZLMImageGalleryItemNIO.h"
#import "ZLMImageLoader.h"

@interface ZLMImageGalleryVC ()

@property (weak, nonatomic) IBOutlet ZLMGalleryView *galleryView;

@end

@implementation ZLMImageGalleryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _galleryView.delegate = self;
    [[ZLMImageLoader sharedInstance] getImagesFromLibraryWithCompletion:^(ZLMLibraryAuthorizationStatus grantedStatus, NSError *error, NSArray<ZLMImage *> *images) {
        NSMutableArray<ZLMImageGalleryItemNIO *> *items = [[NSMutableArray alloc] init];
        if (images != nil) {
            for (ZLMImage *image in images) {
                [items addObject:[[ZLMImageGalleryItemNIO alloc] initWithImage:image
                                                                          size:[_galleryView getItemSize]]];
            }
        }
        [_galleryView setItems:items];
    } queue:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ZLMGalleryView:(ZLMGalleryView *)galleryView didSelectItemAtIndex:(NSUInteger)index {
    
    NSLog(@"%lu",(unsigned long)index);
}


@end
