//
//  ViewController.m
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import "TableViewController.h"
#import "PostTableViewCell.h"
#import "Post.h"
#import "AdConfig.h"
#import "NGBannerPresenter.h"
#import "BannerAdTableViewCell.h"

static const CGFloat GADAdViewHeight = 250;

@interface TableViewController () <UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *loadStateForAds;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSNumber *> *bannerAdViewDidLoadOnIndex;
@property (nonatomic, strong) NSMutableArray<GADBannerView *> *adsToLoad;
@property (nonatomic, strong) NGBannerPresenter *presenter;

@end

@implementation TableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self.tableview registerNib:[PostTableViewCell getNib] forCellReuseIdentifier:[PostTableViewCell cellIdentifier]];
	[self.tableview registerClass:[BannerAdTableViewCell class] forCellReuseIdentifier:[BannerAdTableViewCell cellIdentifier]];
	// self.tableview.rowHeight = UITableViewAutomaticDimension;
	self.tableview.estimatedRowHeight = 100;

	[self addMenuItems];
	[self addBannerAds:0];
	[self preloadNextAd];
	[self.tableview reloadData];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)addMenuItems {
	for (int index = 0; index < 100; index++) {
		NSString *postTitle = [NSString stringWithFormat:@"Post: %zd", index];
		Post *post = [[Post alloc] initWithTitle:postTitle];
		[self.items addObject:post];
	}
}

- (void)addBannerAds:(NSInteger)startIndex {
	[self trySetupPresenter];

	// Ensure subview layout has been performed before accessing subview sizes.
	[self.tableview layoutIfNeeded];

	NSString *adUnitId = self.presenter.adConfig.adUnitId;
	NSInteger listStartIndex = startIndex;
	NSInteger listEndIndex = self.items.count;
	NSArray<NSNumber *> *fixedPositions = [self.presenter getFixedPositionByStartIndex:listStartIndex endIndex:listEndIndex];

	if (fixedPositions.count > 0) {
		for (NSNumber *fixPosition in fixedPositions) {
			NSInteger position = [fixPosition integerValue];
			GADBannerView *bannerView = [self renderBannerViewWithAdUnitId:adUnitId];
			[self.items insertObject:bannerView atIndex:position];
		}
	}

	if (self.presenter.shouldCheckRepeatedAdIndex &&
		[self.presenter.adConfig.repeatedPosition integerValue] > 0) {
		NSInteger startIndex = 0;
		if (fixedPositions.count > 0) {
			startIndex = [fixedPositions.firstObject integerValue];
		} else {
			startIndex = listStartIndex;
		}

		NSInteger repeatedIndex = [self.presenter.adConfig.repeatedPosition integerValue];
		startIndex += repeatedIndex;
		while (startIndex < self.items.count) {
			GADBannerView *bannerView = [self renderBannerViewWithAdUnitId:adUnitId];
			[self.items insertObject:bannerView atIndex:startIndex];
			startIndex += repeatedIndex;
		}
	}
}

- (GADBannerView *)renderBannerViewWithAdUnitId:(NSString *)adUnitId {
	GADBannerView *adView = [[GADBannerView alloc]
							 initWithAdSize:GADAdSizeFromCGSize(
																CGSizeMake(self.tableview.contentSize.width,
																		   GADAdViewHeight))];
	adView.clipsToBounds = true;
	adView.adUnitID = adUnitId;
	adView.rootViewController = self;
	adView.delegate = self;
	[self.adsToLoad addObject:adView];
	self.loadStateForAds[[self referenceKeyForAdView:adView]] = @NO;
	return adView;
}

- (AdConfig *)buildAdConfig {
	AdConfig *config = [[AdConfig alloc] initWithAdUnitId:@"ca-app-pub-3940256099942544/2934735716"
										   fixedPositions:@[@3,@7,@12]
										 repeatedPosition:@8];
	return config;
}

- (void)trySetupPresenter {
	if (_presenter) {
		return;
	}
	AdConfig *adConfig = [self buildAdConfig];
	self.presenter = [[NGBannerPresenter alloc] initWithAdConfig:adConfig];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.items[indexPath.row] isKindOfClass:[Post class]]) {
		return 100;
	}
	else if ([self.items[indexPath.row] isKindOfClass:[GADBannerView class]]) {
		GADBannerView *adView = self.items[indexPath.row];
		NSNumber *result = self.loadStateForAds[[self referenceKeyForAdView:adView]];
		BOOL isLoaded = [result boolValue];
		return isLoaded ? GADAdViewHeight : 0;
	}

	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.items[indexPath.row] isKindOfClass:[Post class]]) {
		Post *post = self.items[indexPath.row];
		PostTableViewCell *postCell =
		[self.tableview dequeueReusableCellWithIdentifier:[PostTableViewCell cellIdentifier]
											 forIndexPath:indexPath];
		postCell.titleLabel.text = [post getPostTitle];
		return postCell;
	} else if ([self.items[indexPath.row] isKindOfClass:[GADBannerView class]]) {
		BannerAdTableViewCell *bannerAdCell =
		[self.tableview dequeueReusableCellWithIdentifier:[BannerAdTableViewCell cellIdentifier]
											 forIndexPath:indexPath];

		return bannerAdCell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([cell isKindOfClass:[BannerAdTableViewCell class]]) {
		BannerAdTableViewCell *bannerAdCell = (BannerAdTableViewCell *)cell;
		for (UIView *subview in bannerAdCell.bannerContentView.subviews) {
			[subview removeFromSuperview];
		}

		GADBannerView *adView = self.items[indexPath.row];
		[bannerAdCell.bannerContentView addSubview:adView];
	}
}

- (void)preloadNextAd {
	if (!self.adsToLoad.count) {
		return;
	}
	GADBannerView *adView = _adsToLoad.firstObject;
	[self.adsToLoad removeObjectAtIndex:0];
	GADRequest *request = [GADRequest request];
	request.testDevices = @[ kGADSimulatorID ];
	[adView loadRequest:request];
}

- (NSString *)referenceKeyForAdView:(GADBannerView *)adView {
	return [[NSString alloc] initWithFormat:@"%p", adView];
}

#pragma mark getter
- (NSMutableDictionary<NSString *, NSNumber *> *)loadStateForAds {
	if (!_loadStateForAds) {
		_loadStateForAds = [[NSMutableDictionary alloc] init];
	}
	return _loadStateForAds;
}

- (NSMutableDictionary<NSIndexPath *, NSNumber *> *)bannerAdViewDidLoadOnIndex {
	if (!_bannerAdViewDidLoadOnIndex) {
		_bannerAdViewDidLoadOnIndex = [[NSMutableDictionary alloc] init];
	}
	return _bannerAdViewDidLoadOnIndex;
}

- (NSMutableArray<GADBannerView *> *)adsToLoad {
	if (!_adsToLoad) {
		_adsToLoad = [[NSMutableArray alloc] init];
	}
	return _adsToLoad;
}

- (NSMutableArray *)items {
	if (!_items) {
		_items = [[NSMutableArray alloc] init];
	}
	return _items;
}


#pragma mark GADBannerView delegate methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	// Mark banner ad as succesfully loaded.
	self.loadStateForAds[[self referenceKeyForAdView:bannerView]] = @YES;
	// Load the next ad in the adsToLoad list.
	[self preloadNextAd];

	NSArray<UITableViewCell *> *visibleCells = self.tableview.visibleCells;
	for (UITableViewCell *visibleCell in visibleCells) {
		if ([visibleCell isKindOfClass:[BannerAdTableViewCell class]]) {
			NSIndexPath *cellIndexPath = [self.tableview indexPathForCell:visibleCell];

			if (!self.bannerAdViewDidLoadOnIndex[cellIndexPath]) {
				[self.tableview reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				self.bannerAdViewDidLoadOnIndex[cellIndexPath] = [NSNumber numberWithBool:YES];
				[self.tableview setNeedsLayout];
				[self.tableview layoutIfNeeded];
			}
		}
	}
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"Failed to receive ad: %@", error.localizedDescription);
	// Load the next ad in the adsToLoad list.
	[self preloadNextAd];
}

@end
