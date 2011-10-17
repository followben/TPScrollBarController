//
//  AppDelegate.m
//  TPScrollBarControllerExample
//
//  Copyright 2011 Ben Stovold. All rights reserved.
//

#import "AppDelegate.h"
#import "TPScrollBarController.h"
#import "TestController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    // Create two view controllers for the contentView.
    TestController *c1 = [[TestController alloc] init];
    TestController *c2 = [[TestController alloc] init];
    
    // Label them so we can see which one is displayed.
    c1.title = @"View Controller 1";
    c2.title = @"View Controller 2";
    
    // Now create some buttons and add one of the view controllers as a target.
    UIButton *b1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b1 setFrame:CGRectMake(0, 0, 100, 50)];
    [b1 setTitle:@"#1 Purple" forState:UIControlStateNormal];
    [b1 addTarget:c1 action:@selector(turnMePurple) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *b2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b2 setFrame:CGRectMake(0, 0, 100, 50)];
    [b2 setTitle:@"#1 Orange" forState:UIControlStateNormal];
    [b2 addTarget:c1 action:@selector(turnMeOrange) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *bmore = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [bmore setFrame:CGRectMake(0, 0, 50, 50)];
    [bmore setTitle:@">>" forState:UIControlStateNormal];
    [bmore addTarget:c2 action:@selector(scrollToPageTwo) forControlEvents:UIControlEventTouchUpInside];

    UIButton *b3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b3 setFrame:CGRectMake(0, 0, 100, 50)];
    [b3 setTitle:@"#2 Orange" forState:UIControlStateNormal];
    [b3 addTarget:c2 action:@selector(turnMeOrange) forControlEvents:UIControlEventTouchUpInside];

    UIButton *b4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [b4 setFrame:CGRectMake(0, 0, 100, 50)];
    [b4 setTitle:@"#2 Purple" forState:UIControlStateNormal];
    [b4 addTarget:c2 action:@selector(turnMePurple) forControlEvents:UIControlEventTouchUpInside];
    
    // Setup the parameters for the scroll bar controller.
    NSSet *viewControllers = [NSSet setWithObjects:c1, c2, nil];
    NSArray *buttons = [NSArray arrayWithObjects:b1, b2, bmore, b3, b4, nil];
    NSArray *pages = [NSArray arrayWithObjects: [NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:1],
                                                [NSNumber numberWithInt:2],
                                                [NSNumber numberWithInt:2], nil];
    
    // Initialise and set the controllers, buttons, pages
    TPScrollBarController *sbc = [[TPScrollBarController alloc] init];
    [sbc setViewControllers:viewControllers WithBarButtons:buttons onScrollBarPages:pages];
    
    // Add an example delegate.
    [sbc setDelegate:c1];
    
    // Assign TPScrollBarController as root.
    self.window.rootViewController = sbc;
    
    [self.window makeKeyAndVisible];
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

@end
