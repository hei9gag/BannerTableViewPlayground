//
//  AdConfig.m
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import "AdConfig.h"

@implementation AdConfig

- (instancetype)initWithAdUnitId:(NSString *)adUnitId
				  fixedPositions:(NSArray<NSNumber *> *)fixedPositions
				repeatedPosition:(NSNumber *)repeatedPosition {
	self = [super init];
	if (self) {
		_adUnitId = adUnitId;
		_fixedPositions = fixedPositions;
		_repeatedPosition = repeatedPosition;
	}
	return self;
}

@end
