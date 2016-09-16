//
//  GifDatabase.h
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Gif;

@interface GifDatabase : NSObject

@property (nonatomic, strong) NSMutableArray <Gif *>* dataSource;

+ (instancetype)sharedDatabase;

- (Gif *)gifWithIdentifier:(NSString *)identifier;
- (Gif *)createAndSaveGifWithData:(NSDictionary *)gifData;

@end
