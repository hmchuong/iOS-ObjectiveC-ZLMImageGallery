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
#import "ZLMPhotoDetailVC.h"

@interface ZLMImageGalleryVC ()

@property (weak, nonatomic) IBOutlet ZLMGalleryView *galleryView;
@property (strong, nonatomic) NSArray<ZLMImage *> *images;

@end

@implementation ZLMImageGalleryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _galleryView.delegate = self;
    [self loadPhotosFromLibrary];
    
}

- (void)loadPhotosFromLibrary {
    ZLMImageLoader *imageLoader = [ZLMImageLoader sharedInstance];
    [imageLoader getImagesFromLibraryWithCompletion:^(ZLMLibraryAuthorizationStatus grantedStatus, NSError *error, NSArray<ZLMImage *> *images) {
        _images = images;
        if (grantedStatus == ZLMLibAuthNotDetermined) {
            
            [imageLoader requestPermission:^{
                [self loadPhotosFromLibrary];
            }];
            return;
        }
        
        NSMutableArray<ZLMImageGalleryItemNIO *> *items = [[NSMutableArray alloc] init];
        if (images != nil) {
            for (ZLMImage *image in images) {
                [items addObject:[[ZLMImageGalleryItemNIO alloc] initWithImage:image
                                                                          size:[_galleryView getItemSize]]];
            }
        }
        [_galleryView setItems:items];
    } queue:nil changedObserver:YES];
}

- (void)ZLMGalleryView:(ZLMGalleryView *)galleryView didSelectItemAtIndex:(NSUInteger)index {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ZLMPhotoDetailVC* detailController = [storyboard instantiateViewControllerWithIdentifier:@"ZLMPhotoDetail"];
    detailController.images = _images;
    detailController.currentIndex = index;
    
    [self.navigationController pushViewController:detailController animated:YES];
}


@end
