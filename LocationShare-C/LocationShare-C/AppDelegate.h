//
//  AppDelegate.h
//  LocationShare-C
//
//  Created by sudhakkar on 07/03/17.
//  Copyright © 2017 perceptionSketch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) sqlite3 *dataBase;

@property (strong, nonatomic) NSString *strDatabasePath;

@property(strong, nonatomic) NSMutableArray *arrayLocation;

-(void)insertUserDataIntoDatabase:(NSString*)dictUserDetails;

-(void)userLocations;

- (void)fetchGreeting;

@end

