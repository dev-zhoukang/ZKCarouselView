//
//  ZKCarouselView.h
//  HTWallet
//
//  Created by ZK on 16/8/5.
//  Copyright © 2016年 MaRuJun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HEADER_INIT_FRAME   (CGRect){CGPointZero, CellSize}

@interface ZKCarouselView : UIView

+ (instancetype)carouselWithImageUrls:(NSArray <NSString *> *)imageUrls;

@end

//////////////////////////////

@interface ZKCarouselViewCell : UICollectionViewCell

#define CellSize    CGSizeMake(SCREEN_WIDTH , 200)

@property (nonatomic, copy) NSString *imageUrl;

@end
