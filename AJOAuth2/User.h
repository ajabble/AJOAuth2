//
//  User.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuthCredential.h"

@interface User : NSObject
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSDate *expiration;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *emailAddress;

- (id)initWithAttributes:(NSMutableDictionary *)userDict;
- (id)initWithCredentials: (AFOAuthCredential *)credential withInfo:(NSArray *)infoArray;

@end
