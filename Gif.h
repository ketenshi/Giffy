//
//  Gif.h
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const gifDataDidChangeNotification;

@interface Gif : NSObject <NSCoding>

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSArray <NSString *> *tags;
@property (strong, nonatomic) NSString *webURL;
@property (nonatomic) BOOL imageDownloaded;
@property (nonatomic) NSUInteger rating;

- (void)saveData;

- (void)saveImage:(NSURL *)tempLocation;

- (NSString *)imagePath;
- (NSString *)thumbnailPath;

@end
