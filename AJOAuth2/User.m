//
//  User.m
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import "User.h"

#define USERNAME @"username"
#define FIRST_NAME @"firstname"
#define LAST_NAME @"lastname"
#define EMAIL_ADDRESS @"email"
#define DOB @"dob"

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
        
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ username:\"%@\" email address:\"%@\" first name:\"%@\" last name:\"%@\" dob:\"%@\">", [self class], _userName, _emailAddress, _firstName, _lastName, _dob];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    _userName = [decoder decodeObjectForKey:USERNAME];
    _firstName = [decoder decodeObjectForKey:FIRST_NAME];
    _lastName = [decoder decodeObjectForKey:LAST_NAME];
    _emailAddress = [decoder decodeObjectForKey:EMAIL_ADDRESS];
    _dob = [decoder decodeObjectForKey:DOB];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_userName forKey:USERNAME];
    [encoder encodeObject:_firstName forKey:FIRST_NAME];
    [encoder encodeObject:_lastName forKey:LAST_NAME];
    [encoder encodeObject:_emailAddress forKey:EMAIL_ADDRESS];
    [encoder encodeObject:_dob forKey:DOB];
}

@end
