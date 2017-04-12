//
//  ViewController.m
//  ZKCarouselViewDemo
//
//  Created by ZK on 2017/4/12.
//  Copyright © 2017年 ZK. All rights reserved.
//

#import "ViewController.h"
#import "ZKCarouselView.h"
#import "Masonry.h"
#import "ZKGlobalHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *imageUrls = @[
                           @"https://devel-10041765.file.myqcloud.com/admin/images/5d9dd8e6-555c-4381-a879-35a03fe29934.jpg",
                           @"https://devel-10041765.file.myqcloud.com/admin/images/a9d3111b-7c37-45ba-b6ea-e9726063b09a.jpg",
                           @"https://devel-10041765.file.myqcloud.com/admin/images/3d65c9b8-0e51-4277-869f-de269102f932.jpg",
                           @"https://devel-10041765.file.myqcloud.com/admin/images/1aa687bd-0460-4aa4-9873-d0049782478f.jpg"
                           ];
    ZKCarouselView *carousel = [ZKCarouselView carouselWithImageUrls:imageUrls];
    [self.view addSubview:carousel];
    carousel.backgroundColor = [UIColor redColor];
    [carousel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(200);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 200));
    }];
}

@end
