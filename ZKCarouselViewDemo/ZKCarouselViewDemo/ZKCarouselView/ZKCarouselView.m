//
//  ZKCarouselView.m
//  HTWallet
//
//  Created by ZK on 16/8/5.
//  Copyright © 2016年 MaRuJun. All rights reserved.
//

#import "ZKCarouselView.h"
#import "ZKGlobalHeader.h"
#import <objc/runtime.h>
#import "UIImageView+WebCache.h"
#import "UIImage+Common.h"
#import "Masonry.h"
#import "ZKTimer.h"
#import "SDImageCache.h"
#import "SDWebImagePrefetcher.h"

@interface ZKCarouselView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray <NSString *> *imageUrls;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl    *pageControl;
@property (nonatomic, strong) ZKTimer *timer;

@end

static const NSUInteger kSectionCount = 80;
static NSString *const kCellIdentifier = @"ZKCarouselViewCell";

@implementation ZKCarouselView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor greenColor];
    [self setupCollectionView];
    [self setupPageControl];
    _timer = [ZKTimer timerWithTimeInterval:2 target:self selector:@selector(handleTimer) repeats:true];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    layout.minimumLineSpacing = layout.minimumInteritemSpacing = 0.f;
    layout.itemSize = CellSize;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self insertSubview:_collectionView atIndex:0];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.clipsToBounds = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.pagingEnabled = YES;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [_collectionView registerClass:[ZKCarouselViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
}

- (void)setupPageControl
{
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.userInteractionEnabled = NO;
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    _pageControl.pageIndicatorTintColor = HexColor(0x7A7A7A);
    _pageControl.hidesForSinglePage = YES;
    [self insertSubview:_pageControl aboveSubview:_collectionView];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.bottom.mas_equalTo(-10);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    if ([self whetherSetValueSafelyForPageControl]) { // 防止访问不存在的私有属性引起crash
        [_pageControl setValue:[UIImage imageNamed:@"page_dot_normal"] forKeyPath:@"_pageImage"];
        [_pageControl setValue:[UIImage imageNamed:@"page_dot_selected"] forKeyPath:@"_currentPageImage"];
    }
}

- (BOOL)whetherSetValueSafelyForPageControl
{
    unsigned int numIvars;
    Ivar *vars = class_copyIvarList([UIPageControl class], &numIvars);
    NSString *key = nil;
    
    NSMutableArray *keys = [NSMutableArray array];
    
    for(int i = 0; i < numIvars; i++) {
        
        Ivar thisIvar = vars[i];
        key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        [keys addObject:key];
    }
    free(vars);
    
    BOOL setValueSafelyForPageControl = [keys containsObject:@"_pageImage"]
                                        && [keys containsObject:@"_currentPageImage"];
    
    return setValueSafelyForPageControl;
}

- (BOOL)imageExits:(NSInteger)item
{
    NSString *urlStr = _imageUrls[item];
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    BOOL imageExits = !![imageCache imageFromCacheForKey:urlStr];
    return imageExits;
}

#pragma mark - 轮播
- (void)handleTimer {
    
    NSIndexPath *currentIndexPath = [_collectionView indexPathsForVisibleItems].lastObject;
    NSInteger next = currentIndexPath.item + 1;
    
     BOOL currentImageExists = [self imageExits:currentIndexPath.item];
    
     BOOL nextImageExists = YES;
     if (next < _imageUrls.count) {
         nextImageExists = [self imageExits:next];
     }
    
     if (!currentImageExists || !nextImageExists) return;
    
    NSIndexPath *currentIndexPathReset = [NSIndexPath indexPathForItem:currentIndexPath.item
                                                             inSection:kSectionCount*0.5];
    [_collectionView scrollToItemAtIndexPath:currentIndexPathReset
                            atScrollPosition:UICollectionViewScrollPositionLeft
                                    animated:NO];
    
    NSInteger nextItem = currentIndexPathReset.item + 1;
    NSInteger nextSection = currentIndexPathReset.section;
    if (nextItem == _imageUrls.count) {
        nextItem = 0;
        nextSection ++;
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextItem
                                                     inSection:nextSection];
    [_collectionView scrollToItemAtIndexPath:nextIndexPath
                            atScrollPosition:UICollectionViewScrollPositionLeft
                                    animated:YES];
}

#pragma mark - Public
+ (instancetype)carouselWithImageUrls:(NSArray<NSString *> *)imageUrls
{
    ZKCarouselView *header = [[ZKCarouselView alloc] init];
    header.backgroundColor = [UIColor clearColor];
    header.imageUrls = imageUrls.count?imageUrls:@[@""];
    header.pageControl.numberOfPages = imageUrls.count;
    
    return header;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _imageUrls.count == 1 ? : kSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imageUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZKCarouselViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.imageUrl = _imageUrls[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollW = scrollView.frame.size.width;
    int page = (int)((scrollView.contentOffset.x + scrollW * 0.5) / scrollW)%_imageUrls.count;
    _pageControl.currentPage = page;
}



@end

///////////////////////////////////

@interface ZKCarouselViewCell()

@property (nonatomic, strong) UIImageView *showImageView;

@end

@implementation ZKCarouselViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.contentView.backgroundColor = [UIColor yellowColor];
    
    _showImageView = [[UIImageView alloc] init];
    _showImageView.clipsToBounds = YES;
    _showImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_showImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _showImageView.frame = self.contentView.bounds;
}

#pragma mark - Setter
- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    
    [_showImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                      placeholderImage:[UIImage imageWithColor:HexColor(0xbbbbbb)]];
}

@end

