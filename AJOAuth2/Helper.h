//
//  Helper.h
//  AJOAuth2
//
//  Created by Ashish Jabble on 23/01/17.
//  Copyright © 2017 Ashish Jabble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (BOOL)isConnected;
+ (BOOL)validateEmail:(NSString *)candidate;

@end
