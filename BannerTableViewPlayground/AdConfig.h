//
//  AdConfig.h
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdConfig : NSObject

@property (nonatomic, readonly) NSString *adUnitId;
@property (nonatomic, readonly) NSArray<NSNumber *> *fixedPositions;
@property (nonatomic, readonly) NSNumber *repeatedPosition;

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
				  fixedPositions:(NSArray<NSNumber *> *)fixedPositions
				repeatedPosition:(NSNumber *)repeatedPosition;

@end
