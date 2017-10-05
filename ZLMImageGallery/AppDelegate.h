//
//  AppDelegate.h
//  ZLMImageGallery
//
//  Created by chuonghm on 10/5/17.
//  Copyright © 2017 VNG Corp., VN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

