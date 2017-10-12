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
#import "MBProgressHUD.h"

@interface ZLMImageGalleryVC ()

@property (weak, nonatomic) IBOutlet ZLMGalleryView         *galleryView;       // Gallery view
@property (weak, nonatomic) IBOutlet UIView                 *detailView;        // Detail view of image
@property (weak, nonatomic) IBOutlet UILabel                *imageNameLbl;      // Label for image's name
@property (weak, nonatomic) IBOutlet FSPagerView            *pagerView;         // Pager view to show image
@property (weak, nonatomic) IBOutlet UIView                 *interactionView;   // View to interaction with Done button

@end

@implementation ZLMImageGalleryVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _galleryView.delegate = self;
    _detailView.hidden = YES;
    [_pagerView registerClass:[FSPagerViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self loadPhotosFromLibrary];
    
    // Gesture for Done button
    UITapGestureRecognizer *tapgesture =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView:)];
    tapgesture.numberOfTouchesRequired=1;
    [_interactionView addGestureRecognizer:tapgesture];
    
}

/**
 Load Photos from Library
 */
- (void)loadPhotosFromLibrary {
    
    // Show progress view
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    
    ZLMImageLoader *imageLoader = [ZLMImageLoader sharedInstance];
    [imageLoader getImagesFromLibraryWithCompletion:^(ZLMLibraryAuthorizationStatus grantedStatus, NSError *error, NSArray<ZLMImage *> *images) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });

        // Request library access
        if (grantedStatus == ZLMLibAuthNotDetermined) {
            
            [imageLoader requestPermission:^{
                [self loadPhotosFromLibrary];
            }];
            return;
        }
        
        if (error || grantedStatus != ZLMLibAuthorized) {
            
            [self showError];
            return;
        }
        
        // Set items for Gallery View
        NSMutableArray<ZLMImageGalleryItemNIO *> *items = [[NSMutableArray alloc] init];
        if (images != nil) {
            for (ZLMImage *image in images) {
                [items addObject:[[ZLMImageGalleryItemNIO alloc] initWithImage:image size:[_galleryView getItemSize]]];
            }
        }
        
        [_galleryView setItems:items];
        
        // Reload pager view
        [_pagerView reloadData];
        
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

#pragma mark - Utilities

/**
 Show error when cannot access library
 */
- (void)showError {
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Cannot access library"
                                                                  message:@"This application cannot access to photo library"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:noButton];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

#pragma mark - Actions

-(void)tapView:(UITapGestureRecognizer *)gesture
{    
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
    
    ZLMImage *image = [(ZLMImageGalleryItemNIO *)[_galleryView getItemAtIndex:index] image];
    
    // Set image view
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = nil;
    
    // Show progress view
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0) ,^{
        
        // Show progress view
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        });
        
        CGSize size = cell.imageView.frame.size;
        if (size.height == 0 || size.width == 0) {
            size = CGSizeMake(300, 300);
        }
        UIImage *requestedImage = [image getImageWithSize:size];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.imageView setImage:requestedImage];
            [_imageNameLbl setText:[image name]];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    // Set label text
    cell.textLabel.text = [NSString stringWithFormat:@"%d/%lu",index+1,(unsigned long)[_galleryView numberOfItems]];
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (NSInteger)numberOfItemsInPagerView:(FSPagerView *)pagerView {
    
    return [_galleryView numberOfItems];
}

@end
