//
//  Gif.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "Gif.h"

@import UIKit;

static NSString * const identifierKey = @"identifier";
static NSString * const tagsKey = @"tags";
static NSString * const webURLKey = @"webURL";
static NSString * const imageDownloadedKey = @"imageDownloaded";

@interface Gif ()

@property (strong, nonatomic) NSString *databaseFilePath;

@end

@implementation Gif

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:identifierKey];
    [aCoder encodeObject:self.tags forKey:tagsKey];
    [aCoder encodeObject:self.webURL forKey:webURLKey];
    [aCoder encodeBool:self.imageDownloaded forKey:imageDownloadedKey];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier = [aDecoder decodeObjectForKey:identifierKey];
    self.tags = [aDecoder decodeObjectForKey:tagsKey];
    self.webURL = [aDecoder decodeObjectForKey:webURLKey];
    self.imageDownloaded = [aDecoder decodeBoolForKey:imageDownloadedKey];
    
    return self;
}

- (void)saveData {
    NSString *documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"data.plist"];
    
    [NSKeyedArchiver archiveRootObject:self toFile:documentsPath];
}

- (void)saveImage:(NSURL *)tempLocation {
    NSData *gifData = [NSData dataWithContentsOfURL:tempLocation];
    UIImage *image = [UIImage imageWithData:gifData];
    
//    UIImage *scaledImage = [Gif imageWithImage:image scaledToFillSize:CGSizeMake(60, 60)];
//    
//    NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
//    
    NSString *documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"image.gif"];
    
    
    [[NSFileManager defaultManager] createFileAtPath:documentsPath contents:gifData attributes:nil];
    
    self.imageDownloaded = YES;;
    
    
    
    UIImage *thumbnail = [Gif imageWithImage:image scaledToFillSize:CGSizeMake(60, 60)];
    
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
    
    NSString *documentsPath2 = [[self databaseFilePath] stringByAppendingPathComponent:@"thumbnail.png"];
    
    [[NSFileManager defaultManager] createFileAtPath:documentsPath2 contents:thumbnailData attributes:nil];
    
    [self saveData];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size {
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f, (size.height - height)/2.0f, width, height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFitSize:(CGSize)size {
    CGFloat scale = MIN(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f, (size.height - height)/2.0f, width, height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)imagePath {
    return [self.databaseFilePath stringByAppendingPathComponent:@"image.gif"];
}

- (NSString *)thumbnailPath {
    return [self.databaseFilePath stringByAppendingPathComponent:@"thumbnail.png"];
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
