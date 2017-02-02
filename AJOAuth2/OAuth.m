//
//  OAuth.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 02/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "OAuth.h"

#define ACCESS_TOKEN @"access_token"
#define REFRESH_TOKEN @"refresh_token"
#define TOKEN_TYPE @"token_type"
#define SCOPE @"scope"
#define EXPIRES_IN @"expires_in"

@implementation OAuth

- (id) init {
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
        
        if (userDict[SCOPE]) {
            _scope = userDict[SCOPE];
            [userDict removeObjectForKey:SCOPE];
        }
        if (userDict[EXPIRES_IN]) {
            _expirationTime = [userDict[EXPIRES_IN] integerValue];
            [userDict removeObjectForKey:EXPIRES_IN];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ access_token:\"%@\" token_type:\"%@\" refresh_token:\"%@\" scope: \"%@\" expiration_time: \"%zd\" >", [self class], _accessToken, _tokenType, _refreshToken, _scope, _expirationTime];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _accessToken = [decoder decodeObjectForKey:ACCESS_TOKEN];
    _tokenType = [decoder decodeObjectForKey:TOKEN_TYPE];
    _refreshToken = [decoder decodeObjectForKey:REFRESH_TOKEN];
    _scope = [decoder decodeObjectForKey:SCOPE];
    _expirationTime = [[decoder decodeObjectForKey:EXPIRES_IN] integerValue];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_accessToken forKey:ACCESS_TOKEN];
    [encoder encodeObject:_tokenType forKey:TOKEN_TYPE];
    [encoder encodeObject:_refreshToken forKey:REFRESH_TOKEN];
    [encoder encodeObject:_scope forKey:SCOPE];
    [encoder encodeObject:[NSNumber numberWithInteger:_expirationTime] forKey:EXPIRES_IN];
}

@end
