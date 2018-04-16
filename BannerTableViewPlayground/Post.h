//
//  Post.h
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

- (instancetype)initWithTitle:(NSString *)title;
- (NSString *)getPostTitle;

@end
