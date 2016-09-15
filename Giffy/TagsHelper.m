//
//  TagsHelper.m
//  Giffy
//
//  Created by Eugene on 2016-09-15.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "TagsHelper.h"

@implementation TagsHelper

+ (instancetype)defaultTagsHelper {
    static TagsHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [TagsHelper new];
    });
    
    return sharedInstance;
}

@end
