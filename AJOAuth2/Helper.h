//
//  Helper.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuth.h"
#import "User.h"

@interface Helper : NSObject

+ (BOOL)isConnected;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (void)oAuthInfoSaveInDefaults:(NSDictionary *)oAuthInfoDict;
+ (void)userInfoSaveInDefaults:(NSDictionary *)userInfoDict;

@end
