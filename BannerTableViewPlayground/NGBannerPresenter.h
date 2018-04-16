//
//  NGBannerPresenter.h
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AdConfig.h"

@interface NGBannerPresenter : NSObject

@property (nonatomic,readonly) AdConfig *adConfig;
@property (nonatomic, readonly) BOOL shouldCheckRepeatedAdIndex;
- (instancetype)initWithAdConfig:(AdConfig *)adConfig;

- (NSArray<NSNumber *> *)getFixedPositionByStartIndex:(NSInteger)startIndex
											 endIndex:(NSInteger)endIndex;

@end
