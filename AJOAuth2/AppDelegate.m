//
//  AppDelegate.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 19/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import <MCLocalization/MCLocalization.h>
#import "Constants.h"
#import "CenterViewController.h"
#import "LeftViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworkReachabilityManager.h"
#import <LGSideMenuController/UIViewController+LGSideMenuController.h>
#import "AFOAuthCredential.h"
#import "AJOauth2ApiClient.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // When application forcefully is deleted/uninstall, credentials are persists in memory; http://stackoverflow.com/questions/3671499/iphone-keychain-items-persist-after-application-uninstall
    // Delete OauthCredentials from keychain items, when invalid user
    [self deleteOauthCredentialsFromKeychainItems];
    
    // start monitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Load JSON file
    NSDictionary * languageURLPairs = @{
                                        @"en":[[NSBundle mainBundle] URLForResource:@"en.json" withExtension:nil],
                                        @"hi":[[NSBundle mainBundle] URLForResource:@"hi.json" withExtension:nil],
                                        };
    [MCLocalization loadFromLanguageURLPairs:languageURLPairs defaultLanguage:@"en"];
    [MCLocalization sharedInstance].noKeyPlaceholder = @"[No '{key}' in '{language}']";
    [MCLocalization sharedInstance].language = @"en";
    
    // SVProgressHUD
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    // Go to Drawer
    [self goToDrawer];
    
    return YES;
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

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    return YES;
}

#pragma mark Drawer

- (void)goToDrawer {
    self.window.backgroundColor = THEME_BG_COLOR;
    
    CenterViewController *rootViewController = [CenterViewController new];
    LeftViewController *leftViewController = [LeftViewController new];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    LGSideMenuController *sideMenuController = [LGSideMenuController sideMenuControllerWithRootViewController:navigationController leftViewController:leftViewController rightViewController:nil];
    
    // Left hand side view
    sideMenuController.leftViewWidth = LEFT_DRAWER_WIDTH; // width of the left drawer
    sideMenuController.leftViewSwipeGestureRange = LGSideMenuSwipeGestureRangeMake(0.0, 88.0);
    sideMenuController.leftViewPresentationStyle = LGSideMenuPresentationStyleScaleFromBig;
    sideMenuController.leftViewAnimationSpeed = 1.0; // speed of animation
    
    // Root view properties (actually the one view which slides after "LEFT" click)
    sideMenuController.rootViewLayerBorderWidth = 5.0; // view border outline
    sideMenuController.rootViewLayerBorderColor = [UIColor whiteColor]; // view border color
    sideMenuController.rootViewLayerShadowRadius = 10.0; // view border radius
    sideMenuController.rootViewScaleForLeftView = 0.6; // view size height
    sideMenuController.rootViewCoverColorForLeftView = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.3]; // BG color of view
    sideMenuController.rootViewCoverBlurEffectForLeftView = [UIBlurEffect effectWithStyle:UIBlurEffectStyleProminent];
    sideMenuController.rootViewCoverAlphaForLeftView = 0.1;
    
    self.window.rootViewController = sideMenuController;
    [self.window makeKeyAndVisible];
}

#pragma mark AFOAuthCredential

- (void)deleteOauthCredentialsFromKeychainItems {
    if (![PREFS objectForKey:USER_INFO])
        [AFOAuthCredential deleteCredentialWithIdentifier:[AJOauth2ApiClient sharedClient].serviceProviderIdentifier];
    else
        NSLog(@"No action needed");
}

@end
