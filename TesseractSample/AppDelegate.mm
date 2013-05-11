//
//  AppDelegate.m
//  TesseractSample
//
//  Created by Ângelo Suzuki on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "KNSecondViewController.h"
#import "DITableViewController.h"
#import "AboutViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
    UIViewController * vc2 = [[KNSecondViewController alloc] initWithNibName:@"KNSecondViewController" bundle:nil];
    DITableViewController *tableView = [[DITableViewController alloc] initWithNibName:@"DITableViewController" bundle:nil];
    AboutViewController  *aboutViewController = [[AboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
     UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:aboutViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:tableView];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[vc2,navController,navController2];
//    self.tabBarController.tabBar.items[0] = [[UITabBarItem alloc] initWithTitle:@"OCR" image:[UIImage imageNamed:@"first"] tag:100];
//    self.tabBarController.tabBar.items[1] = [[UITabBarItem alloc] initWithTitle:@"History" image:[UIImage imageNamed:@"second"] tag:100];
    [self.tabBarController.tabBar.items[0] setTitle:@"OCR"];
    [self.tabBarController.tabBar.items[1] setTitle:@"History"];
    [self.tabBarController.tabBar.items[2] setTitle:@"About"];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    // First tab
//    UIViewController * vc1 = [[KNFirstViewController alloc] initWithNibName:@"KNFirstViewController" bundle:nil];
//    
//    // Second tab
//    UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:vc1];
//    UIViewController * vc2 = [[KNSecondViewController alloc] initWithNibName:@"KNSecondViewController" bundle:nil];
//    
//    // Third tab
//    KNTableDemoController * vc3 = [[KNTableDemoController alloc] initWithStyle:UITableViewStyleGrouped];
//    
//    // About tab
////    KNAboutViewController * ab = [[KNAboutViewController alloc] initWithNibName:@"KNAboutViewController" bundle:nil];
//    
//    self.tabBarController = [[UITabBarController alloc] init];
//    self.tabBarController.viewControllers = [NSArray arrayWithObjects:uinav, vc2, vc3, tableView,nil];
//    self.window.rootViewController = self.tabBarController;
//    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

//

+ (AppDelegate *)appDelegate{		// Static accessor
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSString *)filesDirectoryPath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Files"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filesDirectory]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:filesDirectory withIntermediateDirectories:NO attributes:nil error:&error])
            ;// success
        else
        {
//            DebugLog(@"[%@] ERROR: attempting to write create Files directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
    
    
	return filesDirectory;
}
@end
