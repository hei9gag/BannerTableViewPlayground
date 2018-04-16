//
//  PostTableViewCell.m
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

+ (UINib *)getNib {
	return [UINib nibWithNibName:@"PostTableViewCell" bundle:nil];
}

+ (NSString *)cellIdentifier {
	return @"PostTableViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
