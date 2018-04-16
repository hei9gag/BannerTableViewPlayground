//
//  Post.m
//  BannerTableViewPlayground
//
//  Created by Brian Chung on 16/4/2018.
//  Copyright © 2018 9GAG. All rights reserved.
//

#import "Post.h"

@interface Post()

@property (nonatomic, strong) NSString *postTitle;

@end

@implementation Post

- (instancetype)initWithTitle:(NSString *)title {
	self = [super init];
	if (self) {
		self.postTitle = title;
	}
	return self;
}

- (NSString *)getPostTitle {
	return self.postTitle;
}

@end
