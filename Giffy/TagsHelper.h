//
//  TagsHelper.h
//  Giffy
//
//  Created by Eugene on 2016-09-15.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsHelper : NSObject

@property (strong, nonatomic, readonly) NSArray *tags;

+ (instancetype)defaultTagsHelper;
- (NSArray *)tagSuggestionsWithSubstring:(NSString *)substring limit:(NSUInteger)limit;

@end
