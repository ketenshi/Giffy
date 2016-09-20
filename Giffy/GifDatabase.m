//
//  GifDatabase.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "GifDatabase.h"

#import "Gif.h"
@implementation GifDatabase

+ (instancetype)sharedDatabase {
    static GifDatabase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [GifDatabase new];
    });
    
    return sharedInstance;
}

- (void)loadDatabase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *databaseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    databaseDirectory = [databaseDirectory stringByAppendingPathComponent:@"Database"];
    
    NSArray *contentsOfDirectory = [fileManager contentsOfDirectoryAtPath:databaseDirectory error:nil];
    
    for (NSString *directory in contentsOfDirectory) {
        if ([directory.pathExtension compare:@"gifData" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *plistPath = [NSString pathWithComponents:@[databaseDirectory, directory,@"data.plist"]];
            Gif *gif = [NSKeyedUnarchiver unarchiveObjectWithFile:plistPath];
            [self.dataSource addObject:gif];
        }
    }
}

- (Gif *)gifWithIdentifier:(NSString *)identifier {
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.identifier = %@",identifier];
    NSArray *result = [self.dataSource filteredArrayUsingPredicate:searchPredicate];
    return [result firstObject];
}

- (Gif *)createAndSaveGifWithData:(NSDictionary *)gifData {
    Gif *gif = [Gif new];
    gif.identifier = gifData[@"id"];
    gif.tags = [gifData[@"tags"] componentsSeparatedByString:@","];
    gif.webURL = gifData[@"url"];
    
    [gif saveData];
    
    [self.dataSource addObject:gif];
    
    return gif;
}

#pragma mark Lazy

- (NSMutableArray<Gif *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        [self loadDatabase];
    }
    return _dataSource;
}

@end
