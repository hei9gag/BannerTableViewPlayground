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
	}
	return self;
}

- (NSArray<NSNumber *> *)getFixedPositionByStartIndex:(NSInteger)startIndex
											 endIndex:(NSInteger)endIndex {
	NSArray<NSNumber *> *fixedPositions = _adConfig.fixedPositions;
	if (fixedPositions.count == 0) {
		return @[];
	}

	NSMutableArray<NSNumber *> *result = [[NSMutableArray alloc] init];
	for (NSNumber *fixedPosition in fixedPositions) {
		NSInteger position = [fixedPosition integerValue];
		if (position >= startIndex && position <= endIndex) {
			[result insertObject:fixedPosition atIndex:0];
		}
	}

	return result;
}

- (BOOL)shouldSetupRepeatedAdIndexAd:(NSInteger)endIndex {
	if (self.adConfig.fixedPositions.count == 0) {
		return YES;
	}

	if ([self.adConfig.repeatedPosition integerValue] == 0) {
		return NO;
	}

	return endIndex > [self.adConfig.fixedPositions.lastObject integerValue];
}

// returns index with ad
- (NSIndexPath *)adIndex:(NSIndexPath *)originalIndex {
	NSInteger numOfAd = 0;
	NSInteger indexWithAd = originalIndex.row;
	NSArray<NSNumber *> *fixedPositions = self.adConfig.fixedPositions;
	if (fixedPositions.count > 0) {
		for (NSNumber *fixedPosition in fixedPositions) {
			if (originalIndex.row > fixedPosition.integerValue) {
				numOfAd += 1;
			}
		}
	}

	NSInteger repeatedAdPosition = [self.adConfig.repeatedPosition integerValue];
	if (numOfAd == fixedPositions.count &&
		repeatedAdPosition > 0) {
		NSInteger lastFixedPosition = self.adConfig.fixedPositions.lastObject.integerValue;
		NSInteger repeatedAdStartIndex = lastFixedPosition + 1;
		numOfAd += (originalIndex.row - repeatedAdStartIndex) / repeatedAdPosition;
	}

	indexWithAd += numOfAd;
	return [NSIndexPath indexPathForRow:indexWithAd inSection:originalIndex.section];
}

@end
