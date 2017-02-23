//
//  User.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "User.h"

NSString *const USERNAME = @"username";
NSString *const FIRST_NAME = @"firstname";
NSString *const LAST_NAME = @"lastname";
NSString *const EMAIL_ADDRESS = @"email";
NSString *const DOB = @"dob";
NSString *const IMAGE_URL = @"image_url";

@implementation User

-(id) init {
    self = [super init];
    if (self) {}
    
    return self;
}

#pragma mark Overrided functions

- (id)initWithAttributes:(NSMutableDictionary *)userDict {
    if (self = [super init]) {
        if (userDict[USERNAME]) {
            _userName = userDict[USERNAME];
            [userDict removeObjectForKey:USERNAME];
        }
        
        if (userDict[FIRST_NAME]) {
            _firstName = userDict[FIRST_NAME];
            [userDict removeObjectForKey:FIRST_NAME];
        }
        if (userDict[LAST_NAME]) {
            _lastName = userDict[LAST_NAME];
            [userDict removeObjectForKey:LAST_NAME];
        }
        if (userDict[EMAIL_ADDRESS]) {
            _emailAddress = userDict[EMAIL_ADDRESS];
            [userDict removeObjectForKey:EMAIL_ADDRESS];
        }
        if (userDict[DOB]) {
            _dob = userDict[DOB];
            [userDict removeObjectForKey:DOB];
        }
        if (userDict[IMAGE_URL]) {
            _avatarImageURLString = userDict[IMAGE_URL];
            [userDict removeObjectForKey:IMAGE_URL];
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username:\"%@\" email address:\"%@\" first name:\"%@\" last name:\"%@\" dob:\"%@\" image :\"%@\">", [self class], _userName, _emailAddress, _firstName, _lastName, _dob, _avatarImageURLString];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _userName = [decoder decodeObjectForKey:USERNAME];
    _firstName = [decoder decodeObjectForKey:FIRST_NAME];
    _lastName = [decoder decodeObjectForKey:LAST_NAME];
    _emailAddress = [decoder decodeObjectForKey:EMAIL_ADDRESS];
    _dob = [decoder decodeObjectForKey:DOB];
    _avatarImageURLString = [decoder decodeObjectForKey:IMAGE_URL];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_userName forKey:USERNAME];
    [encoder encodeObject:_firstName forKey:FIRST_NAME];
    [encoder encodeObject:_lastName forKey:LAST_NAME];
    [encoder encodeObject:_emailAddress forKey:EMAIL_ADDRESS];
    [encoder encodeObject:_dob forKey:DOB];
    [encoder encodeObject:_avatarImageURLString forKey:IMAGE_URL];
}

@end
