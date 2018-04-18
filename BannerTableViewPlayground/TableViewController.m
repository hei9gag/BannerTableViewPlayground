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
@property (nonatomic, strong) NSMutableArray *postItems;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *loadStateForAds;
// @property (nonatomic, strong) NSMutableDictionary<NSIndexPath *, NSNumber *> *bannerAdViewDidLoadOnIndex;
@property (nonatomic, strong) NSMutableArray<GADBannerView *> *adsToLoad;
@property (nonatomic, strong) NGBannerPresenter *bannerPresenter;

@end

@implementation TableViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	[self.tableview registerNib:[PostTableViewCell getNib] forCellReuseIdentifier:[PostTableViewCell cellIdentifier]];
	[self.tableview registerClass:[BannerAdTableViewCell class] forCellReuseIdentifier:[BannerAdTableViewCell cellIdentifier]];
	// self.tableview.rowHeight = UITableViewAutomaticDimension;
	self.tableview.estimatedRowHeight = 100;

	// Ensure subview layout has been performed before accessing subview sizes.
	[self.tableview layoutIfNeeded];

	[self addMenuItems];
	// [self addBannerAds:0 endIndex:self.postItems.count];
	[self preloadNextAd];
	[self.tableview reloadData];

	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(userDidTapAddButton:)];
	self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)addMenuItems {
	NSInteger startIndex = self.postItems.count;
	NSMutableArray *newPosts = [[NSMutableArray alloc] init];
	for (NSInteger index = startIndex; index < startIndex + 10; index++) {
		NSString *postTitle = [NSString stringWithFormat:@"Post: %zd", index];
		Post *post = [[Post alloc] initWithTitle:postTitle];
		post.originalIndex = index;
		[newPosts addObject:post];
	}
	[self.postItems addObjectsFromArray:newPosts];

	NSMutableArray *combindedList = [self addBannerAds:startIndex endIndex:self.postItems.count - 1 source:newPosts];
	[self.items addObjectsFromArray:combindedList];
}

// start index without ad
- (NSMutableArray *)addBannerAds:(NSInteger)startIndex endIndex:(NSInteger)endIndex source:(NSMutableArray *)source {
	[self trySetupPresenter];

	NSString *adUnitId = self.bannerPresenter.adConfig.adUnitId;
	NSInteger numOfAdAdded = 0;
	NSMutableArray *resultList = [[NSMutableArray alloc] initWithArray:source];
	NSArray<NSNumber *> *fixedPositions = [self.bannerPresenter getFixedPositionByStartIndex:startIndex endIndex:endIndex];
	if (fixedPositions.count > 0) {
		for (NSNumber *fixPosition in fixedPositions) {
			NSInteger position = [fixPosition integerValue] + 1 - startIndex; // cause the ad will append to the target index, therefore we need to plus 1 here
			GADBannerView *bannerView = [self renderBannerViewWithAdUnitId:adUnitId];
			if (position < resultList.count) {
				[resultList insertObject:bannerView atIndex:position];
				numOfAdAdded += 1;
			} else {
				[resultList addObject:bannerView];
				numOfAdAdded += 1;
			}
		}
	}
	
	if ([self.bannerPresenter shouldSetupRepeatedAdIndexAd:endIndex]) {
		NSInteger repeatedAdIndex = 0;
		NSInteger repeatedPosition = [self.bannerPresenter.adConfig.repeatedPosition integerValue];
		NSInteger previousAdStartIndex = 0;
		if (self.bannerPresenter.adConfig.fixedPositions.count > 0) {
			repeatedAdIndex = self.bannerPresenter.adConfig.fixedPositions.lastObject.integerValue + 1;
		} else {
			repeatedAdIndex = 0;
		}

		if (startIndex > repeatedAdIndex) {
			// find previous repeated ad index
			repeatedAdIndex = startIndex - ((startIndex - repeatedAdIndex) % repeatedPosition);
			previousAdStartIndex = repeatedAdIndex;
		}

		repeatedAdIndex += repeatedPosition;
		while (repeatedAdIndex <= endIndex) {
			GADBannerView *bannerView = [self renderBannerViewWithAdUnitId:adUnitId];
			NSUInteger insertIndex = repeatedAdIndex - startIndex + numOfAdAdded;
			// NSLog(@"[BannerAd] repeatedAdStartIndex: %zd insertIndex: %zd", repeatedAdIndex, insertIndex);
			if (insertIndex < resultList.count) {
				[resultList insertObject:bannerView atIndex:insertIndex];
				numOfAdAdded += 1;
			}
			repeatedAdIndex += repeatedPosition;
		}
		// handle case where the banner display at the end of index
		if (repeatedAdIndex == (endIndex + 1) &&
			(repeatedAdIndex - previousAdStartIndex) % repeatedPosition == 0) {
			GADBannerView *bannerView = [self renderBannerViewWithAdUnitId:adUnitId];
			[resultList addObject:bannerView];
		}
	}
	return resultList;
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
										   fixedPositions:@[@3,@6,@9]
										 repeatedPosition:@5];
	return config;
}

- (void)trySetupPresenter {
	if (_bannerPresenter) {
		return;
	}
	AdConfig *adConfig = [self buildAdConfig];
	self.bannerPresenter = [[NGBannerPresenter alloc] initWithAdConfig:adConfig];
}

- (void)userDidTapAddButton:(id)sender {
	[self addMenuItems];
	[self preloadNextAd];
	[self.tableview reloadData];
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
		postCell.titleLabel.text = [NSString stringWithFormat:@"%@ - ad index: %zd", [post getPostTitle], indexPath.row];
		postCell.post = post;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableview deselectRowAtIndexPath:indexPath animated:true];
	PostTableViewCell *postCell = [self.tableview cellForRowAtIndexPath:indexPath];
	Post *selectedPost = postCell.post;
	NSUInteger foundIndex = [self.postItems indexOfObject:selectedPost];
	// NSInteger originalIndex = [self.presenter originalIndex:indexPath].row;
	NSIndexPath *originalIndexPath = [NSIndexPath indexPathForRow:postCell.post.originalIndex inSection:indexPath.section];
	NSInteger indexWithAd = [self.bannerPresenter adIndex:originalIndexPath].row;
	// NSLog(@"[BannerAd] indexWithAd: %zd", indexWithAd);
	NSLog(@"[BannerAd] originalIndex: %zd indexWithAd: %zd", foundIndex, indexWithAd);
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

- (NSMutableArray *)postItems {
	if (!_postItems) {
		_postItems = [[NSMutableArray alloc] init];
	}
	return _postItems;
}


#pragma mark GADBannerView delegate methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
	// Mark banner ad as succesfully loaded.
	self.loadStateForAds[[self referenceKeyForAdView:bannerView]] = @YES;
	// Load the next ad in the adsToLoad list.
	[self preloadNextAd];

	/*
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
	}*/
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"Failed to receive ad: %@", error.localizedDescription);
	// Load the next ad in the adsToLoad list.
	[self preloadNextAd];
}

@end
