//
//  Helper.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "Helper.h"
#import "SVProgressHUD.h"
#import "AFNetworkReachabilityManager.h"
#import "Constants.h"

static SVProgressHUD *HUD;

@implementation Helper

+ (BOOL)isConnected {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

+ (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

+ (void)oAuthInfoSaveInDefaults:(NSDictionary *)oAuthInfoDict {
    OAuth *auth = [[OAuth alloc] initWithAttributes:[oAuthInfoDict mutableCopy]];
    NSLog(@"%@", auth.description);
    NSData *myOAuthEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:auth];
    [PREFS setObject:myOAuthEncodedObject forKey:OAUTH_INFO];
    [PREFS synchronize];
}

+ (void)userInfoSaveInDefaults:(NSDictionary *)userInfoDict {
    User *user = [[User alloc] initWithAttributes:[userInfoDict mutableCopy]];
    NSLog(@"%@", user.description);
    NSData *myUserEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [PREFS setObject:myUserEncodedObject forKey:USER_INFO];
    [PREFS synchronize];
}

@end
