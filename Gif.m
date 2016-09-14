//
//  Gif.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "Gif.h"

static NSString * const identifierKey = @"identifier";
static NSString * const webURLKey = @"webURL";
static NSString * const imageDownloadedKey = @"imageDownloaded";

@interface Gif ()

@property (strong, nonatomic) NSString *databaseFilePath;

@end

@implementation Gif

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:identifierKey];
    [aCoder encodeObject:self.webURL forKey:webURLKey];
    [aCoder encodeBool:self.imageDownloaded forKey:imageDownloadedKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier = [aDecoder decodeObjectForKey:identifierKey];
    self.webURL = [aDecoder decodeObjectForKey:webURLKey];
    self.imageDownloaded = [aDecoder decodeBoolForKey:imageDownloadedKey];
    
    return self;
}

- (void)saveData {
    NSString *documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"data.plist"];
    
    [NSKeyedArchiver archiveRootObject:self toFile:documentsPath];
}

- (void)saveImage:(NSURL *)tempLocation {
    NSString *documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"image.gif"];
    
    NSData *gifData = [NSData dataWithContentsOfURL:tempLocation];
    [[NSFileManager defaultManager] createFileAtPath:documentsPath contents:gifData attributes:nil];
    
    self.imageDownloaded = YES;;
    
    [self saveData];
}

- (NSString *)imagePath {
    return [self.databaseFilePath stringByAppendingPathComponent:@"image.gif"];
}

- (NSString *)databaseFilePath {
    if (!_databaseFilePath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        documentsPath = [NSString pathWithComponents:@[documentsPath, @"Database", self.identifier]];
        documentsPath = [documentsPath stringByAppendingPathExtension:@"gifData"];
        
        if (![fileManager fileExistsAtPath:documentsPath]) {
            [fileManager createDirectoryAtPath:documentsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }

        _databaseFilePath = documentsPath;
    }
    return _databaseFilePath;
}

@end
