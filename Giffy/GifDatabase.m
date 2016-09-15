//
//  GifDatabase.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "GifDatabase.h"

#import "Gif.h"

@interface GifDatabase ()
@end

@implementation GifDatabase

+ (instancetype)sharedDatabase {
    static GifDatabase *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [GifDatabase new];
    });
    
    return sharedInstance;
}

- (void)saveData {
//    self.dataSource = [NSMutableArray array];
    
    Gif *gif1 = [Gif new];
    gif1.identifier = @"1";
    gif1.webURL = @"asdlgjlkj";
    
//    [self.dataSource addObject:gif1];
    
    Gif *gif2 = [Gif new];
    gif2.identifier = @"3";
    gif2.webURL = @"asdlgjlkj";
    
//    [self.dataSource addObject:gif2];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    documentsPath = [documentsPath stringByAppendingPathComponent:@"Database"];
    
    if (![fileManager fileExistsAtPath:documentsPath]) {
        [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    documentsPath = [documentsPath stringByAppendingPathComponent:@"data.plist"];
    
    [gif1 saveData];
    [gif2 saveData];
    
//    BOOL y= [NSKeyedArchiver archiveRootObject:self.dataSource toFile:documentsPath];
    
    
//    NSArray *b = [NSKeyedUnarchiver unarchiveObjectWithFile:documentsPath];
    
    self.dataSource;
    
    Gif *gif3 = [self gifWithIdentifier:@"1"];
    
    NSLog(@"A");
}

- (NSMutableArray<Gif *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        [self loadDatabase];
    }
    return _dataSource;
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
    gif.tags = gifData[@"tags"];
    gif.webURL = gifData[@"url"];
    
    [gif saveData];
    
    return gif;
}

@end
