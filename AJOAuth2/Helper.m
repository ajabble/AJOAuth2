//
//  Helper.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "Helper.h"
#import "AFNetworkReachabilityManager.h"
#import "AFOAuthCredential.h"
#import "AJOauth2ApiClient.h"
#import "SVProgressHUD.h"

NSInteger const kErrorRequestTimeOut = -1001;
NSInteger const kErrorUnsupportedURL = -1002;
NSInteger const kErrorCannotFindHost = -1003;

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

+ (void)saveUserInfoInDefaults:(NSDictionary *)userInfo {
    User *user = [[User alloc] initWithAttributes:[userInfo mutableCopy]];
    NSLog(@"%@", user.description);
    NSData *myUserEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [PREFS setObject:myUserEncodedObject forKey:USER_INFO];
    [PREFS synchronize];
}

+ (BOOL)checkResponseObject:(id)responseObject {
    NSDictionary *jsonDict = (NSDictionary *)responseObject;
    if (!jsonDict)
        return NO;
    if ([jsonDict isKindOfClass:[NSDictionary class]] == NO)
        NSAssert(NO, @"Expected an Dictionary, got %@", NSStringFromClass([jsonDict class]));
    
    NSLog(@"%@", jsonDict);
    
    return YES;
}
+ (BOOL)isWebUrlValid:(NSError *)error {
    if (error.code == kErrorRequestTimeOut || error.code == kErrorUnsupportedURL || error.code == kErrorCannotFindHost) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        return NO;
    }
    
    return YES;
}
+ (User *)getUserPrefs {
    NSData *userInfoObject = [PREFS objectForKey:USER_INFO];
    User *user = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:userInfoObject];
    
    return user;
}

+ (void)removeUserPrefs {
    // Remove credentials from NSUserDefaults as well as from AFOAuthCredential
    [AFOAuthCredential deleteCredentialWithIdentifier:[AJOauth2ApiClient sharedClient].serviceProviderIdentifier];
    [PREFS removeObjectForKey:USER_INFO];
    [PREFS synchronize];
}

@end
