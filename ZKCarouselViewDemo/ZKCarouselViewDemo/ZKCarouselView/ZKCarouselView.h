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

+ (instancetype)headerWithImageUrls:(NSArray <NSString *> *)imageUrls;

@end

//////////////////////////////

@interface ZKCarouselViewCell : UICollectionViewCell

#define CellSize    CGSizeMake(SCREEN_WIDTH , ceil(200*WindowZoomScale))

@property (nonatomic, copy) NSString *imageUrl;

@end
