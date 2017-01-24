//
//  User.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "User.h"

#define ACCESS_TOKEN @"accessToken"
#define REFRESH_TOKEN @"refreshToken"
#define TOKEN_TYPE @"tokenType"
#define EXPIRATION @"expiration"

#define USERNAME @"username"
#define EMAIL_ADDRESS @"email"

@implementation User

-(id) init {
    self = [super init];
    if (self) {}
    
    return self;
}

#pragma mark Overrided functions

- (id)initWithAttributes:(NSMutableDictionary *)userDict {
    if (self = [super init]) {
        if (userDict[ACCESS_TOKEN]) {
            _accessToken = userDict[ACCESS_TOKEN];
            [userDict removeObjectForKey:ACCESS_TOKEN];
        }
        
        if (userDict[TOKEN_TYPE]) {
            _tokenType = userDict[TOKEN_TYPE];
            [userDict removeObjectForKey:TOKEN_TYPE];
        }
        
        if (userDict[REFRESH_TOKEN]) {
            _refreshToken = userDict[REFRESH_TOKEN];
            [userDict removeObjectForKey:REFRESH_TOKEN];
        }
        
        if (userDict[EXPIRATION]) {
            _expiration = userDict[EXPIRATION];
            [userDict removeObjectForKey:EXPIRATION];
        }
        
        if (userDict[USERNAME]) {
            _userName = userDict[USERNAME];
            [userDict removeObjectForKey:USERNAME];
        }
        
        if (userDict[EMAIL_ADDRESS]) {
            _emailAddress = userDict[EMAIL_ADDRESS];
            [userDict removeObjectForKey:EMAIL_ADDRESS];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ accessToken:\"%@\" tokenType:\"%@\" refreshToken:\"%@\" expiration:\"%@\" username:\"%@\" email address:\"%@\">", [self class], _accessToken, _tokenType, _refreshToken, _expiration, _userName, _emailAddress];
}

- (id)initWithCredentials: (AFOAuthCredential *)credential withInfo:(NSArray *)infoArray {
    if (credential !=nil) {
        _accessToken = credential.accessToken;
        _tokenType = credential.tokenType;
        _refreshToken = credential.refreshToken;
        _tokenType = credential.tokenType;
    }
    if (infoArray != nil) {
        _userName = [[infoArray objectAtIndex:0] objectForKey:USERNAME];
        _emailAddress = [[infoArray objectAtIndex:0] objectForKey:EMAIL_ADDRESS];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _accessToken = [decoder decodeObjectForKey:ACCESS_TOKEN];
    _tokenType = [decoder decodeObjectForKey:TOKEN_TYPE];
    _refreshToken = [decoder decodeObjectForKey:REFRESH_TOKEN];
    _expiration = [decoder decodeObjectForKey:EXPIRATION];
    _userName = [decoder decodeObjectForKey:USERNAME];
    _emailAddress = [decoder decodeObjectForKey:EMAIL_ADDRESS];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_accessToken forKey:ACCESS_TOKEN];
    [encoder encodeObject:_tokenType forKey:TOKEN_TYPE];
    [encoder encodeObject:_refreshToken forKey:REFRESH_TOKEN];
    [encoder encodeObject:_expiration forKey:EXPIRATION];
    [encoder encodeObject:_userName forKey:USERNAME];
    [encoder encodeObject:_emailAddress forKey:EMAIL_ADDRESS];
}

@end
