//
//  Gif.m
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import "Gif.h"

@import UIKit;

// NSCoding keys
static NSString * const identifierKey = @"identifier";
static NSString * const tagsKey = @"tags";
static NSString * const webURLKey = @"webURL";
static NSString * const imageDownloadedKey = @"imageDownloaded";
static NSString * const ratingKey = @"rating";

// NSNotification key
NSString * const gifDataDidChangeNotification = @"gifDataDidChangeNotification";

typedef NS_ENUM(NSInteger, imageScaleOption) {
    imageScaleOptionFit,
    imageScaleOptionFill
};

@interface Gif ()

@property (strong, nonatomic) NSString *databaseFilePath;

@end

@implementation Gif

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.identifier = [aDecoder decodeObjectForKey:identifierKey];
    self.tags = [aDecoder decodeObjectForKey:tagsKey];
    self.webURL = [aDecoder decodeObjectForKey:webURLKey];
    self.imageDownloaded = [aDecoder decodeBoolForKey:imageDownloadedKey];
    self.rating = [aDecoder decodeIntegerForKey:ratingKey];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:identifierKey];
    [aCoder encodeObject:self.tags forKey:tagsKey];
    [aCoder encodeObject:self.webURL forKey:webURLKey];
    [aCoder encodeBool:self.imageDownloaded forKey:imageDownloadedKey];
    [aCoder encodeInteger:self.rating forKey:ratingKey];
}

- (void)saveData {
    NSString *documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"data.plist"];
    
    [NSKeyedArchiver archiveRootObject:self toFile:documentsPath];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:gifDataDidChangeNotification object:self];
}

- (void)saveImage:(NSURL *)tempLocation {
    NSData *gifData = [NSData dataWithContentsOfURL:tempLocation];
    UIImage *image = [UIImage imageWithData:gifData];
    
    NSString *documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"image.gif"];
    [[NSFileManager defaultManager] createFileAtPath:documentsPath contents:gifData attributes:nil];
    
    UIImage *thumbnail = [Gif imageWithImage:image scaledToSize:CGSizeMake(60, 60) scaleOption:imageScaleOptionFill];
    
    NSData *thumbnailData = UIImagePNGRepresentation(thumbnail);
    
    documentsPath = [[self databaseFilePath] stringByAppendingPathComponent:@"thumbnail.png"];
    [[NSFileManager defaultManager] createFileAtPath:documentsPath contents:thumbnailData attributes:nil];
    
    self.imageDownloaded = YES;
    
    [self saveData];
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

#pragma mark - Image Helper

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)size scaleOption:(imageScaleOption)option {
    CGFloat scale;
    switch (option) {
        case imageScaleOptionFill:
            scale = MAX(size.width/image.size.width, size.height/image.size.height);
            break;
        case imageScaleOptionFit:
        default:
            scale = MIN(size.width/image.size.width, size.height/image.size.height);
            break;
    }
    
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f, (size.height - height)/2.0f, width, height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
