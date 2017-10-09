//
//  ZLMGalleryItemNICell.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMGalleryItemNICell.h"
#import "ZLMGalleryItemNIO.h"

@implementation ZLMGalleryItemNICell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self setupView];
    
    return self;
}

- (void)setupView {
    
    _thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
    _thumbnail.contentMode = UIViewContentModeScaleToFill;
    _thumbnail.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addSubview:_thumbnail];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[thumbnail]|" options:0 metrics:nil views:@{@"thumbnail":_thumbnail}]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[thumbnail]|" options:0 metrics:nil views:@{@"thumbnail":_thumbnail}]];
    
    [self setNeedsUpdateConstraints];
}

- (BOOL)shouldUpdateCellWithObject:(ZLMGalleryItemNIO *)object {
    
    [_thumbnail setImage:[object getThumbnailImage]];
    return YES;
}

@end
