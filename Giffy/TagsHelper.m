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

- (NSArray *)tags {
    static NSArray *_tags = nil;
    
    if (!_tags) {
        NSString *tagFilePath = [[NSBundle mainBundle] pathForResource:@"tags" ofType:@"json"];
        NSData *tagData = [NSData dataWithContentsOfFile:tagFilePath];
        _tags = [NSJSONSerialization JSONObjectWithData:tagData options:0 error:nil];
    }
    return _tags;
}

- (NSArray *)tagSuggestionsWithSubstring:(NSString *)substring limit:(NSUInteger)limit {
    NSArray *suggestions;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", substring];
    suggestions = [self.tags filteredArrayUsingPredicate:predicate];
    
    return [suggestions subarrayWithRange:NSMakeRange(0, MIN(suggestions.count, limit))];
}

@end
