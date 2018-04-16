//
//  BannerAdTableViewCell.h
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerAdTableViewCell : UITableViewCell

+ (NSString *)cellIdentifier;
@property (nonatomic, readonly) UIView *bannerContentView;

@end
