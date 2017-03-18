//
//  AppDelegate.m
//  LocationShare-C
//
//  Created by sudhakkar on 07/03/17.
//  Copyright © 2017 perceptionSketch. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize dataBase,strDatabasePath,arrayLocation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self createDabase];
    return YES;
}

-(void)createDabase
{
    NSString *docDirct;
    NSArray *dirpath;
    
    //get directory
    dirpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docDirct = dirpath[0];
    
    // build the path
    strDatabasePath = [[NSString alloc] initWithString:[docDirct stringByAppendingPathComponent:@"loation.db"]];
    
    NSLog(@"database path.%@",strDatabasePath);
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr fileExistsAtPath:strDatabasePath] == NO)
    {
        const char *dbPath = [strDatabasePath UTF8String];
        
        if (sqlite3_open(dbPath, &dataBase) == SQLITE_OK)
        {
            
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS LOCATION (ID INTEGER PRIMARY KEY AUTOINCREMENT, LONGLAT)";
            
            if (sqlite3_exec(dataBase, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                
                NSLog(@"Failed to create table");
            }
//            sqlite3_exec(dataBase,sql_stmt,NULL,NULL, NULL);

            sqlite3_close(dataBase);
            
        }
        
        else{
            NSLog(@"failed to open/ create db");
            
        }
    }
    
}

-(void)insertUserDataIntoDatabase:(NSString*)dictUserDetails
{
    
    NSString *strLoc = dictUserDetails;
    
   
    NSLog(@"String location... %@", strLoc);

    sqlite3_stmt *statement;
    const char *dbpath = [strDatabasePath UTF8String];
    
    if (sqlite3_open(dbpath, &dataBase)== SQLITE_OK )
    {
        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO LOCATION (LONGLAT) VALUES (\"%@\")",strLoc];
        
        const char *insert_stmt = [insertSql UTF8String];
        
        sqlite3_prepare_v2(dataBase, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"location added");
            
        }
        else{
            NSLog(@"failed to add location");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(dataBase);
                               
        
    }
}
-(void)userLocations
{
    const char *dbpath = [strDatabasePath UTF8String];
    sqlite3_stmt *statment;
    
    if(sqlite3_open(dbpath, &dataBase) == SQLITE_OK)
    {
        NSString *querysql = [NSString stringWithFormat:@"SELECT * FROM LOCATION"];
        
         char const *query_stmt = [querysql UTF8String];
        NSLog(@"query :%@",querysql);
        
        if (sqlite3_prepare_v2(dataBase, query_stmt, -1, &statment, NULL) == SQLITE_OK ) {
            
            if (sqlite3_step(statment) == SQLITE_ROW) {
                

                NSString *logLatfield =[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statment, 0)];
                
                arrayLocation = [[NSMutableArray alloc]init];
                
                
                while(sqlite3_step(statment) == SQLITE_ROW)
                {
                    
                    [arrayLocation addObject:[NSString stringWithFormat:@"%s",(char *) sqlite3_column_text(statment, 1)]];
                    NSLog(@"loaction arrey..%@", arrayLocation.description);
                }
                
                NSLog(@"content...%@",logLatfield);
                
            }
            else{
                NSLog(@"match  not found");
            }
            
            sqlite3_finalize(statment);
            
        }
        sqlite3_close(dataBase);
    }
    
}

- (void)fetchGreeting
{
    NSURL *url = [NSURL URLWithString:@"http://rest-service.guides.spring.io/greeting"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
//             self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
//             self.greetingContent.text = [greeting objectForKey:@"content"];
         }
     }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
