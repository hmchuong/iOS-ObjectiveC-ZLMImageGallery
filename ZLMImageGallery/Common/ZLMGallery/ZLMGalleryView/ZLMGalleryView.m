//
//  ZLMGalleryView.m
//  ZLMImageGallery
//
//  Created by chuonghm on 10/9/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import "ZLMGalleryView.h"

@interface ZLMGalleryView()

#pragma mark - Outlets

@property (strong, nonatomic) UICollectionView                  *galleryCollectionView;          // Collection view for gallery

#pragma mark - Nimbus model

@property (retain, nonatomic) NIMutableCollectionViewModel      *galleryItemsModel;             // Gallery items model
@property (strong, nonatomic) NSArray<ZLMGalleryItemNIO *>      *items;                         // items array

@end

@implementation ZLMGalleryView

#pragma mark - Constructors

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setupProperties];
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self setupProperties];
        [self setupView];
    }
    return self;
}

#pragma mark - Setup

/**
 Set up properties
 */
- (void)setupProperties {
    
    // Size
    _numOfItemsPerRow = DEFAULT_NUM_OF_ITEM_PER_ROW;
    _minSpace = DEFAULT_MIN_SPACE;
    _items = [[NSArray alloc] init];
    
    // Init model
    _galleryItemsModel = [[NIMutableCollectionViewModel alloc] initWithDelegate:self];
    _galleryItemsModel.delegate = self;
    [_galleryItemsModel addSectionWithTitle:@""];
}

/**
 Setup views
 */
- (void)setupView {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Create collection view
    _galleryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self flowLayout]];
    
    _galleryCollectionView.delegate = self;
    _galleryCollectionView.dataSource = _galleryItemsModel;
    
    _galleryCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _galleryCollectionView.showsVerticalScrollIndicator = YES;
    _galleryCollectionView.showsHorizontalScrollIndicator = NO;
    _galleryCollectionView.backgroundColor = [UIColor clearColor];
    _galleryCollectionView.allowsMultipleSelection = NO;
    
    [self addSubview:_galleryCollectionView];
    
    // Constraints
    // ----- Top
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_galleryCollectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    // ----- Bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_galleryCollectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    
    // ----- Leading and trailing
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":_galleryCollectionView}]];
}

/**
 Get flow layout of collection view

 @return flow layout of collection view
 */
- (UICollectionViewFlowLayout *)flowLayout {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];    flowLayout.itemSize = [self getItemSize];
    flowLayout.sectionInset = UIEdgeInsetsMake(_minSpace, _minSpace, _minSpace, _minSpace);
    flowLayout.minimumLineSpacing = _minSpace;
    flowLayout.minimumInteritemSpacing = _minSpace;
    
    return flowLayout;
}

#pragma mark - Public methods

- (void)setNumOfItemsPerRow:(NSUInteger)numOfItemsPerRow {
    
    _numOfItemsPerRow = numOfItemsPerRow;
    
    _galleryCollectionView.collectionViewLayout = [self flowLayout];
}

- (void)setMinSpace:(NSUInteger)minSpace {
    
    _minSpace = minSpace;
    
    _galleryCollectionView.collectionViewLayout = [self flowLayout];
}

- (void)setItems:(NSArray<ZLMGalleryItemNIO *> *)items {
    
#if DEBUG
    NSAssert(items != nil, @"Items array is null");
#endif
    _items = items;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_galleryItemsModel removeSectionAtIndex:0];
        [_galleryItemsModel addSectionWithTitle:@""];
        [_galleryItemsModel addObjectsFromArray:items];
        [_galleryCollectionView reloadData];
    });
}

- (ZLMGalleryItemNIO *)getItemAtIndex:(NSUInteger)index {
    
    if ([_items count] > index) {
        return [_items objectAtIndex:index];
    } else {
        return nil;
    }
}

- (CGSize)getItemSize {
    
    CGFloat cellWidth = ([UIScreen mainScreen].bounds.size.width - _minSpace * (_numOfItemsPerRow + 1))/ _numOfItemsPerRow;
    return CGSizeMake(cellWidth, cellWidth);
}

- (NSUInteger)numberOfItems {
    return [_items count];
}

#pragma mark - NimbusDelegate

- (UICollectionViewCell *)collectionViewModel:(NICollectionViewModel *)collectionViewModel cellForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    
    return [NICollectionViewCellFactory collectionViewModel:collectionViewModel
                                      cellForCollectionView:collectionView
                                                atIndexPath:indexPath
                                                 withObject:object];
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(ZLMGalleryView:didSelectItemAtIndex:)]) {
        [_delegate ZLMGalleryView:self didSelectItemAtIndex:indexPath.row];
    }
}


@end
