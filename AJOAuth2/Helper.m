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

#pragma mark Validations

+ (BOOL)isConnected {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    return [AFNetworkReachabilityManager sharedManager].reachable;
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

#pragma mark User Preferences

+ (void)saveUserInfoInDefaults:(NSDictionary *)userInfo {
    User *user = [[User alloc] initWithAttributes:[userInfo mutableCopy]];
    NSLog(@"%@", user.description);
    NSData *myUserEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    [PREFS setObject:myUserEncodedObject forKey:USER_INFO];
    [PREFS synchronize];
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

#pragma mark Localization

+ (NSDictionary *)getLanguages {
    return @{
             @"languages": @[
                     @{ @"internal_name":@"en" , @"display_name":@"English" },
                     @{ @"internal_name":@"hi" , @"display_name":@"Hindi"}
                     ]
             };
}

+ (NSDictionary *)loadLanguagesFromUrl {
    NSArray *languages = [[self getLanguages] objectForKey:@"languages"];
    NSMutableArray *languageKeyArray = [NSMutableArray new];
    for (NSDictionary *key in languages) {
        //NSLog(@"Key: %@", key[@"internal_name"]);
        [languageKeyArray addObject:key[@"internal_name"]];
    }
    NSMutableDictionary *languageURLPairs = [NSMutableDictionary new];
    [languageKeyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        NSLog(@"%@ -- %zd -- %zd", obj, index, stop);
        NSString *key = [languageKeyArray objectAtIndex:index];
        [languageURLPairs addEntriesFromDictionary:@{key:[[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"%@.json", key] withExtension:nil]}];
    }];
    
    return [languageURLPairs mutableCopy];
}

+ (NSDictionary *)displayLanguages {
    NSMutableDictionary *languageDict = [NSMutableDictionary new];
    NSArray *languages = [[Helper getLanguages] objectForKey:@"languages"];
    NSMutableArray *languageKeyArray = [NSMutableArray new];
    for (NSDictionary *key in languages) {
        //NSLog(@"Key: %@", key[@"internal_name"]);
        [languageKeyArray addObject:key[@"internal_name"]];
        [languageKeyArray addObject:key[@"display_name"]];
    }
    for (NSUInteger i = 0; i < languageKeyArray.count/2; i++) {
        NSString *key = [languageKeyArray objectAtIndex:2 * i];
        NSString *value = [languageKeyArray objectAtIndex:2 * i + 1];
        [languageDict addEntriesFromDictionary:@{key:value}];
    }
    NSLog(@"%@", languageDict.description);
    
    return [languageDict mutableCopy];
}

#pragma mark UIImage-Scaling

+ (UIImage *)scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    // UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSData *)avatarImageUrl:(NSString *)avatarImageURLString {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", HOST_URL, avatarImageURLString];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString: urlString]];
    
    return imageData;
}
@end
