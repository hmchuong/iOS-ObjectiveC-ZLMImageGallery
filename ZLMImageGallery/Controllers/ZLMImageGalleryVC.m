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
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *imageNameLbl;
@property (weak, nonatomic) IBOutlet FSPagerView *pagerView;
@property (strong, nonatomic) NSArray<ZLMImage *> *images;

@end

@implementation ZLMImageGalleryVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _galleryView.delegate = self;
    
    _detailView.hidden = YES;
    
    [_pagerView registerClass:[FSPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self loadPhotosFromLibrary];
    
}

/**
 Load Photos from Library
 */
- (void)loadPhotosFromLibrary {
    
    ZLMImageLoader *imageLoader = [ZLMImageLoader sharedInstance];
    [imageLoader getImagesFromLibraryWithCompletion:^(ZLMLibraryAuthorizationStatus grantedStatus, NSError *error, NSArray<ZLMImage *> *images) {
        
        _images = images;
        [_pagerView reloadData];
        
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

#pragma mark - ZLMGalleryView Delegate

- (void)ZLMGalleryView:(ZLMGalleryView *)galleryView didSelectItemAtIndex:(NSUInteger)index {
    
    // Zoom in photo
    _detailView.hidden = NO;
    _detailView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.2
                     animations:^{
                         _detailView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Scroll to image
    [_pagerView scrollToItemAtIndex:index animated:NO];
}

#pragma mark - Actions

- (IBAction)doneBtnClicked:(UIButton *)sender {
    
    // Zoom out photo
    [UIView animateWithDuration:0.2
                     animations:^{
                         _detailView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
                     } completion:^(BOOL finished) {
                         _detailView.hidden = YES;
                     }];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - FSPagerView Delegate

- (FSPagerViewCell *)pagerView:(FSPagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    
    FSPagerViewCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:@"cell" atIndex:index];
    
    ZLMImage *image = [_images objectAtIndex:index];
    
    // Set image view
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = cell.imageView.frame.size;
    if (size.height == 0 || size.width == 0) {
        size = CGSizeMake(300, 300);
    }
    cell.imageView.image = [image getImageWithSize:size];
    
    // Set label text
    cell.textLabel.text = [NSString stringWithFormat:@"%ld/%lu",index+1,(unsigned long)[_images count]];
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    // Set file name
    [_imageNameLbl setText:[image name]];
    
    return cell;
}

- (NSInteger)numberOfItemsInPagerView:(FSPagerView *)pagerView {
    return [_images count];
}

@end
