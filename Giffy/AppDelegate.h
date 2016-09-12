//
//  AppDelegate.h
//  Giffy
//
//  Created by Eugene on 2016-09-11.
//  Copyright © 2016 Eugene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

