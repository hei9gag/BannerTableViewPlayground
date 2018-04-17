//
//  PostTableViewCell.h
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) Post *post;

+ (UINib *)getNib;
+ (NSString *)cellIdentifier;

@end
