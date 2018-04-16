//
//  BannerAdTableViewCell.m
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import "BannerAdTableViewCell.h"


@implementation BannerAdTableViewCell
@synthesize bannerContentView;

+ (NSString *)cellIdentifier {
	return @"BannerAdTableViewCell";
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.clipsToBounds = true;
		[self.contentView addSubview:self.bannerContentView];
	}
	return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.bannerContentView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIView *)bannerContentView {
	if (!bannerContentView) {
		bannerContentView = [[UIView alloc] init];
		bannerContentView.clipsToBounds = true;
		bannerContentView.backgroundColor = self.backgroundColor;
	}
	return bannerContentView;
}

@end
