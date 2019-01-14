//
//  AppDelegate.h
//  Bamboo
//
//  Created by Matthew Burnett on 11/5/12.
//  Copyright (c) 2012 Matthew Burnett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UISplitViewController *splitViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
