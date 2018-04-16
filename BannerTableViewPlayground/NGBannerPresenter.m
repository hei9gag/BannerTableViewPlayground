//
//  NGBannerPresenter.m
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import "NGBannerPresenter.h"

@interface NGBannerPresenter()


@end

@implementation NGBannerPresenter

- (instancetype)initWithAdConfig:(AdConfig *)adConfig {
	self = [super init];
	if (self) {
		_adConfig = adConfig;
		_shouldCheckRepeatedAdIndex = NO;
	}
	return self;
}

- (NSArray<NSNumber *> *)getFixedPositionByStartIndex:(NSInteger)startIndex
											 endIndex:(NSInteger)endIndex {
	NSArray<NSNumber *> *fixedPositions = _adConfig.fixedPositions;
	if (fixedPositions.count == 0) {
		_shouldCheckRepeatedAdIndex = YES;
		return @[];
	}

	NSMutableArray<NSNumber *> *result = [[NSMutableArray alloc] init];
	for (NSNumber *fixedPosition in fixedPositions) {
		NSInteger position = [fixedPosition integerValue];
		if (position >= startIndex && position < endIndex) {
			[result insertObject:fixedPosition atIndex:0];
		}
	}

	if (endIndex > [_adConfig.fixedPositions.lastObject integerValue]) {
		_shouldCheckRepeatedAdIndex = YES;
	}
	return result;
}

/*
- (BOOL)isAdIndex:(NSInteger)row {
	NSArray<NSNumber *> *fixedPositions = _adConfig.fixedPositions;
	if (fixedPositions.count != 0) {
		for (NSInteger i = 0; i < fixedPositions.count && row <= [fixedPositions.lastObject integerValue] + 1; i++) {
			if (row == fixedPositions[i].integerValue + 1) {
				return YES;
			}
		}
	}

	if (_shouldCheckRepeatedAdIndex) {

	}
	return NO;
}*/


@end
