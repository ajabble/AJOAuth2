//
//  OAuth.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 02/02/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuth : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSString *tokenType;
@property (nonatomic, copy) NSString *scope;
@property (nonatomic, assign) NSInteger expirationTime;

- (id)initWithAttributes:(NSMutableDictionary *)userDict;

@end
