//
//  Gif.h
//  Giffy
//
//  Created by Eugene on 2016-09-13.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gif : NSObject <NSCoding>

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSArray <NSString *> *tags;
@property (strong, nonatomic) NSString *webURL;
@property (nonatomic) BOOL imageDownloaded;

- (void)saveData;

- (void)saveImage:(NSURL *)tempLocation;

- (NSString *)imagePath;
@end
